-- 🚀 WHATSAPP MESAJ KUYRUĞU - TAMAMEN SQL İLE
-- Self-hosted Supabase için (Edge Functions olmadan)
-- PostgreSQL + pg_cron + http extension kullanır

-- ============================================
-- ADIM 1: GEREKLİ EXTENSİONLARI AKTIFLEŞTIR
-- ============================================

-- HTTP istekleri yapmak için
CREATE EXTENSION IF NOT EXISTS http;

-- Zamanlanmış görevler için (cron job)
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- ============================================
-- ADIM 2: WHATSAPP MESAJ GÖNDERME FONKSİYONU
-- ============================================

CREATE OR REPLACE FUNCTION public.send_whatsapp_from_queue()
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    queue_record RECORD;
    phone_formatted text;
    api_response http_response;
    result_json json;
    success_count integer := 0;
    failed_count integer := 0;
    total_count integer := 0;
    
    -- Evolution API bilgileri (buraya kendi bilgilerini yaz)
    evolution_api_url text := 'https://evo-2.edu-ai.online';
    evolution_api_key text := 'iHAF8gWNA1axdRDY9e98UKpork00dBO2'; -- BURAYA KEYİNİ YAZ!
BEGIN
    -- Gönderilecek mesajları al (maksimum 10 adet)
    FOR queue_record IN
        SELECT *
        FROM public."messageQueue"
        WHERE status = 'pending'
        AND "scheduledFor" <= NOW()
        ORDER BY "scheduledFor" ASC
        LIMIT 10
    LOOP
        total_count := total_count + 1;
        
        BEGIN
            -- Telefon numarasını formatla
            phone_formatted := REGEXP_REPLACE(queue_record.phone, '[^0-9]', '', 'g');
            
            -- Türkiye numarası ise +90 ekle
            IF LENGTH(phone_formatted) = 10 THEN
                phone_formatted := '90' || phone_formatted;
            ELSIF phone_formatted LIKE '0%' THEN
                phone_formatted := '9' || phone_formatted;
            END IF;
            
            phone_formatted := phone_formatted || '@s.whatsapp.net';
            
            -- Evolution API'ye POST isteği gönder
            SELECT * INTO api_response
            FROM http((
                'POST',
                evolution_api_url || '/message/sendText/' || queue_record."deviceId",
                ARRAY[
                    http_header('Content-Type', 'application/json'),
                    http_header('apikey', evolution_api_key)
                ],
                'application/json',
                json_build_object(
                    'number', phone_formatted,
                    'text', queue_record.message
                )::text
            )::http_request);
            
            -- API yanıtı başarılı mı kontrol et
            IF api_response.status BETWEEN 200 AND 299 THEN
                -- Başarılı: Status güncelle
                UPDATE public."messageQueue"
                SET status = 'sent'
                WHERE id = queue_record.id;
                
                -- WhatsApp mesaj logunu kaydet
                INSERT INTO public."whatsappMessages" (
                    id,
                    "clubId",
                    "toNumber",
                    "messageText",
                    "deviceId",
                    "instanceName",
                    status,
                    "sentAt",
                    "createdAt"
                ) VALUES (
                    'msg_' || gen_random_uuid()::text,
                    queue_record."clubId",
                    queue_record.phone,
                    queue_record.message,
                    queue_record."deviceId",
                    queue_record."deviceId",
                    'sent',
                    NOW(),
                    NOW()
                ) ON CONFLICT DO NOTHING;
                
                success_count := success_count + 1;
                
                RAISE NOTICE 'Mesaj gönderildi: % (ID: %)', queue_record.phone, queue_record.id;
            ELSE
                -- Başarısız: Hata kaydet
                UPDATE public."messageQueue"
                SET 
                    status = 'failed',
                    error = 'API Error: ' || api_response.status || ' - ' || api_response.content
                WHERE id = queue_record.id;
                
                failed_count := failed_count + 1;
                
                RAISE WARNING 'Mesaj gönderilemedi: % (API Status: %)', queue_record.phone, api_response.status;
            END IF;
            
            -- Rate limiting: Mesajlar arası 2 saniye bekle
            PERFORM pg_sleep(2);
            
        EXCEPTION
            WHEN OTHERS THEN
                -- Beklenmeyen hata: Kaydet
                UPDATE public."messageQueue"
                SET 
                    status = 'failed',
                    error = SQLERRM
                WHERE id = queue_record.id;
                
                failed_count := failed_count + 1;
                
                RAISE WARNING 'Hata oluştu: % (ID: %)', SQLERRM, queue_record.id;
        END;
    END LOOP;
    
    -- Sonucu JSON olarak döndür
    result_json := json_build_object(
        'success', true,
        'processed', success_count,
        'failed', failed_count,
        'total', total_count,
        'timestamp', NOW()
    );
    
    RAISE NOTICE 'İşlem tamamlandı: % başarılı, % hatalı, % toplam', success_count, failed_count, total_count;
    
    RETURN result_json;
END;
$$;

-- ============================================
-- ADIM 3: CRON JOB OLUŞTUR (HER DAKİKA ÇALIŞIR)
-- ============================================

-- Önce varsa eski cron job'u sil (hata verirse önemli değil)
DO $$
BEGIN
    PERFORM cron.unschedule('whatsapp-queue-processor');
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Eski cron job bulunamadı, devam ediliyor...';
END $$;

-- Yeni cron job oluştur (her dakika çalışır)
SELECT cron.schedule(
    'whatsapp-queue-processor',           -- Job adı
    '* * * * *',                          -- Her dakika (cron formatı)
    $$SELECT public.send_whatsapp_from_queue();$$
);

-- ============================================
-- ADIM 4: TEST ET
-- ============================================

-- Manuel test (şimdi çalıştır)
SELECT public.send_whatsapp_from_queue();

-- Sonuç şöyle olmalı:
-- {"success": true, "processed": 2, "failed": 0, "total": 2, "timestamp": "2025-11-15..."}

-- ============================================
-- ADIM 5: TEST MESAJI EKLE
-- ============================================

-- Test mesajı ekle
INSERT INTO public."messageQueue" (
    id,
    "clubId",
    phone,
    message,
    "deviceId",
    "recipientName",
    status,
    "scheduledFor",
    "createdAt"
) VALUES (
    'test_' || gen_random_uuid()::text,
    'atakumtenis',                        -- Kendi club ID'n
    '05449367543',                        -- Test telefon
    'WhatsApp mesaj kuyruğu SQL ile çalışıyor! 🚀',
    'atakumtenis',                        -- WhatsApp instance
    'Test Kullanıcı',
    'pending',
    NOW(),                                -- Hemen gönder
    NOW()
);

-- 1 dakika içinde otomatik gönderilecek!
-- Veya manuel test için:
-- SELECT public.send_whatsapp_from_queue();

-- ============================================
-- İZLEME SORULARI
-- ============================================

-- Cron job'lar listesi
SELECT * FROM cron.job WHERE jobname = 'whatsapp-queue-processor';

-- Cron job çalışma geçmişi
SELECT * FROM cron.job_run_details 
WHERE jobid = (SELECT jobid FROM cron.job WHERE jobname = 'whatsapp-queue-processor')
ORDER BY start_time DESC 
LIMIT 10;

-- Bekleyen mesajlar
SELECT * FROM "messageQueue" WHERE status = 'pending' ORDER BY "scheduledFor" ASC;

-- Gönderilen mesajlar (son 10)
SELECT * FROM "messageQueue" WHERE status = 'sent' ORDER BY id DESC LIMIT 10;

-- Başarısız mesajlar (son 10)
SELECT * FROM "messageQueue" WHERE status = 'failed' ORDER BY id DESC LIMIT 10;

-- ============================================
-- SORUN GİDERME
-- ============================================

-- Cron job çalışıyor mu?
SELECT 
    jobname,
    schedule,
    active,
    jobid
FROM cron.job 
WHERE jobname = 'whatsapp-queue-processor';

-- Son çalıştırma sonucu
SELECT 
    start_time,
    end_time,
    status,
    return_message
FROM cron.job_run_details
WHERE jobid = (SELECT jobid FROM cron.job WHERE jobname = 'whatsapp-queue-processor')
ORDER BY start_time DESC
LIMIT 1;

-- ============================================
-- YÖNETİM KOMUTLARI
-- ============================================

-- Cron job'u durdur
-- SELECT cron.unschedule('whatsapp-queue-processor');

-- Cron job'u tekrar başlat
-- SELECT cron.schedule(
--     'whatsapp-queue-processor',
--     '* * * * *',
--     $$SELECT public.send_whatsapp_from_queue();$$
-- );

-- Fonksiyonu sil (gerekirse)
-- DROP FUNCTION IF EXISTS public.send_whatsapp_from_queue();

-- ============================================
-- NOTLAR
-- ============================================

/*
✅ AVANTAJLAR:
- Tamamen SQL ile çalışır
- Edge Functions gerektirmez
- Self-hosted Supabase'de çalışır
- 7/24 otomatik çalışır
- Web sitesi kapalı olsa bile mesaj gönderir

⚙️ AYARLAR:
- evolution_api_url: Evolution API adresi
- evolution_api_key: Evolution API anahtarı (FONKSİYON İÇİNDE DEĞİŞTİR!)
- LIMIT 10: Her çalıştırmada maksimum 10 mesaj gönderir
- pg_sleep(2): Mesajlar arası 2 saniye bekler (rate limiting)

📊 İZLEME:
- cron.job: Zamanlanmış görevler
- cron.job_run_details: Çalışma geçmişi
- RAISE NOTICE/WARNING: PostgreSQL log'larında görünür

🔧 GEREKSİNİMLER:
- PostgreSQL 12+
- http extension
- pg_cron extension
- Evolution API erişimi

🚨 ÖNEMLİ:
- Evolution API Key'i fonksiyon içinde değiştir!
- Test mesajı göndererek kontrol et
- Log'ları takip et
*/
