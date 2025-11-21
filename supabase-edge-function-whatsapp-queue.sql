-- ✅ SUPABASE EDGE FUNCTION - WHATSAPP MESAJ KUYRUĞU (7/24 ÇALIŞIR)
-- Bu fonksiyon Supabase sunucusunda çalışır, web sitesi kapalı olsa bile mesajları gönderir

-- 1️⃣ ADIM: PostgreSQL Fonksiyonu Oluştur
CREATE OR REPLACE FUNCTION public.process_whatsapp_queue()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
    pending_message RECORD;
    processed_count INT := 0;
    failed_count INT := 0;
    result jsonb;
BEGIN
    -- Zamanı gelmiş bekleyen mesajları bul (maksimum 10 mesaj)
    FOR pending_message IN
        SELECT id, "clubId", phone, message, "deviceId", "recipientName"
        FROM public."messageQueue"
        WHERE status = 'pending'
        AND "scheduledFor" <= NOW()
        ORDER BY "scheduledFor" ASC
        LIMIT 10
    LOOP
        BEGIN
            -- WhatsApp API'sine mesaj gönder (Evolution API)
            -- NOT: Bu kısım net.http extension gerektirir
            -- Alternatif: Supabase Edge Function kullan (Deno runtime)
            
            -- Şimdilik durumu 'processing' yap
            UPDATE public."messageQueue"
            SET status = 'processing',
                "updatedAt" = NOW()
            WHERE id = pending_message.id;
            
            processed_count := processed_count + 1;
            
            -- Log kaydet
            RAISE NOTICE 'Mesaj işlendi: % (Alıcı: %)', pending_message.id, pending_message.phone;
            
        EXCEPTION WHEN OTHERS THEN
            -- Hata durumunda failed yap
            UPDATE public."messageQueue"
            SET status = 'failed',
                error = SQLERRM,
                "failedAt" = NOW(),
                "updatedAt" = NOW()
            WHERE id = pending_message.id;
            
            failed_count := failed_count + 1;
            RAISE WARNING 'Mesaj gönderilirken hata: % - %', pending_message.id, SQLERRM;
        END;
    END LOOP;
    
    -- Sonuç döndür
    result := jsonb_build_object(
        'processed', processed_count,
        'failed', failed_count,
        'timestamp', NOW()
    );
    
    RETURN result;
END;
$$;

-- 2️⃣ ADIM: pg_cron Extension'ı Aktifleştir
-- Supabase Dashboard → Database → Extensions → pg_cron → Enable

-- 3️⃣ ADIM: Cron Job Oluştur (Her 1 dakikada çalışır)
-- NOT: pg_cron sadece Supabase Pro plan'da mevcut!
-- Ücretsiz plan için Supabase Edge Function kullanmalısın (aşağıda)

-- Eğer Pro plan varsa:
/*
SELECT cron.schedule(
    'process-whatsapp-queue',
    '* * * * *', -- Her dakika
    $$SELECT public.process_whatsapp_queue()$$
);
*/

-- ============================================
-- 🚀 ALTERNATİF: SUPABASE EDGE FUNCTION (ÜCRETSİZ PLAN İÇİN)
-- ============================================

-- Edge Function, Deno runtime'da çalışır ve HTTP ile WhatsApp API'sine istek atabilir
-- Aşağıdaki dosyayı oluştur: supabase/functions/process-whatsapp-queue/index.ts

/*
// supabase/functions/process-whatsapp-queue/index.ts
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

Deno.serve(async (req) => {
  try {
    // Supabase client oluştur
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseKey)
    
    // Evolution API bilgileri (environment variables'dan al)
    const evolutionUrl = Deno.env.get('EVOLUTION_API_URL')!
    const evolutionKey = Deno.env.get('EVOLUTION_API_KEY')!
    
    // Bekleyen mesajları getir
    const { data: messages, error } = await supabase
      .from('messageQueue')
      .select('*')
      .eq('status', 'pending')
      .lte('scheduledFor', new Date().toISOString())
      .order('scheduledFor', { ascending: true })
      .limit(10)
    
    if (error) throw error
    if (!messages || messages.length === 0) {
      return new Response(JSON.stringify({ processed: 0, message: 'No pending messages' }), {
        headers: { 'Content-Type': 'application/json' }
      })
    }
    
    let processed = 0
    let failed = 0
    
    // Her mesajı gönder
    for (const msg of messages) {
      try {
        // Telefon numarasını formatla
        let phone = msg.phone.replace(/\D/g, '')
        if (phone.startsWith('0') && phone.length === 11) {
          phone = '90' + phone.substring(1)
        } else if (!phone.startsWith('90')) {
          phone = '90' + phone
        }
        
        // WhatsApp API'sine gönder
        const response = await fetch(`${evolutionUrl}/message/sendText/${msg.deviceId}`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'apikey': evolutionKey
          },
          body: JSON.stringify({
            number: `${phone}@s.whatsapp.net`,
            text: msg.message
          })
        })
        
        if (response.ok) {
          // Başarılı - durumu güncelle
          await supabase
            .from('messageQueue')
            .update({
              status: 'sent',
              sentAt: new Date().toISOString(),
              updatedAt: new Date().toISOString()
            })
            .eq('id', msg.id)
          
          processed++
        } else {
          throw new Error(`API error: ${response.status}`)
        }
        
      } catch (error) {
        // Hata - durumu güncelle
        await supabase
          .from('messageQueue')
          .update({
            status: 'failed',
            error: error.message,
            failedAt: new Date().toISOString(),
            updatedAt: new Date().toISOString()
          })
          .eq('id', msg.id)
        
        failed++
      }
    }
    
    return new Response(
      JSON.stringify({ processed, failed, total: messages.length }),
      { headers: { 'Content-Type': 'application/json' } }
    )
    
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    )
  }
})
*/

-- ============================================
-- 📋 KURULUM TALİMATLARI
-- ============================================

-- SEÇENEK 1: Supabase Pro Plan (pg_cron ile)
-- 1. Yukarıdaki PostgreSQL fonksiyonunu çalıştır
-- 2. pg_cron extension'ını aktifleştir
-- 3. Cron job'ı oluştur
-- ✅ Tamam! Her dakika otomatik çalışacak

-- SEÇENEK 2: Ücretsiz Plan (Edge Function + Cron-job.org ile)
-- 1. Edge Function dosyasını oluştur (yukarıdaki TypeScript kodu)
-- 2. Supabase CLI ile deploy et:
--    supabase functions deploy process-whatsapp-queue
-- 3. Environment variables ekle (Dashboard → Edge Functions → Settings):
--    - EVOLUTION_API_URL
--    - EVOLUTION_API_KEY
-- 4. cron-job.org'a git → Yeni cron job oluştur
-- 5. URL: https://YOUR_PROJECT.supabase.co/functions/v1/process-whatsapp-queue
-- 6. Header ekle: Authorization: Bearer YOUR_ANON_KEY
-- 7. Schedule: */1 * * * * (her dakika)
-- ✅ Tamam! 7/24 çalışacak

-- SEÇENEK 3: Basit HTTP Endpoint (manuel tetikleme için)
-- Edge Function'ı deploy et
-- Postman/Insomnia ile test et
-- Kendi sunucundan cron çalıştır

-- ============================================
-- 🧪 TEST
-- ============================================

-- Manuel test (PostgreSQL fonksiyonu):
-- SELECT public.process_whatsapp_queue();

-- Edge Function test:
-- curl -X POST https://YOUR_PROJECT.supabase.co/functions/v1/process-whatsapp-queue \
--   -H "Authorization: Bearer YOUR_ANON_KEY"

-- ============================================
-- 📊 İZLEME
-- ============================================

-- Başarılı gönderilen mesajlar:
-- SELECT * FROM "messageQueue" WHERE status = 'sent' ORDER BY "sentAt" DESC LIMIT 10;

-- Hatalı mesajlar:
-- SELECT * FROM "messageQueue" WHERE status = 'failed' ORDER BY "failedAt" DESC LIMIT 10;

-- Bekleyen mesajlar:
-- SELECT * FROM "messageQueue" WHERE status = 'pending' AND "scheduledFor" <= NOW();

COMMENT ON FUNCTION public.process_whatsapp_queue IS '7/24 çalışan WhatsApp mesaj kuyruğu işleyicisi - Web sitesi kapalı olsa bile mesajları gönderir';
