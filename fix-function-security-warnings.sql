-- ✅ Supabase Güvenlik Uyarıları Düzeltmesi
-- https://supabase.com/docs/guides/database/database-linter?lint=0011_function_search_path_mutable
-- Tüm fonksiyonlara SECURITY DEFINER ve SET search_path = '' ekleniyor

-- =====================================================
-- 🗑️ ÖNCELİKLE ESKİ TRIGGER'LARI VE FONKSİYONLARI SİL
-- =====================================================
-- Önce trigger'ları sil (fonksiyonlara bağımlı olabilirler)
DROP TRIGGER IF EXISTS trigger_update_whatsapp_packages_updated_at ON public.whatsapp_packages;
DROP TRIGGER IF EXISTS whatsapp_packages_updated_at ON public.whatsapp_packages;

-- Sonra fonksiyonları sil
DROP FUNCTION IF EXISTS public.send_whatsapp_from_queue();
DROP FUNCTION IF EXISTS public.update_whatsapp_packages_updated_at();
DROP FUNCTION IF EXISTS public.update_whatsapp_balance(TEXT, INTEGER, TEXT, TEXT);
DROP FUNCTION IF EXISTS public.check_upcoming_payments();
DROP FUNCTION IF EXISTS public.check_overdue_payments();
DROP FUNCTION IF EXISTS public.check_trial_reminders();

-- =====================================================
-- 1️⃣ SEND_WHATSAPP_FROM_QUEUE
-- =====================================================
CREATE OR REPLACE FUNCTION public.send_whatsapp_from_queue()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
    queue_item RECORD;
    api_url TEXT;
    api_key TEXT;
    request_body JSONB;
    response_data JSONB;
BEGIN
    -- Bekleyen mesajları al (en fazla 10 tane)
    FOR queue_item IN 
        SELECT * FROM public.whatsapp_queue 
        WHERE status = 'pending' 
        ORDER BY created_at ASC 
        LIMIT 10
    LOOP
        BEGIN
            -- Evolution API URL'i oluştur
            api_url := 'https://evoapi.sporcum.com.tr/message/sendText/' || queue_item.instance_name;
            api_key := 'B6477E75-1910-4F4C-8071-6A90DE4629FA';
            
            -- Request body'yi hazırla
            request_body := jsonb_build_object(
                'number', queue_item.phone_number,
                'text', queue_item.message_text,
                'delay', 1200
            );
            
            -- Evolution API'ye POST isteği gönder
            SELECT content::jsonb INTO response_data
            FROM public.http((
                'POST',
                api_url,
                ARRAY[
                    public.http_header('Content-Type', 'application/json'),
                    public.http_header('apikey', api_key)
                ],
                'application/json',
                request_body::text
            )::public.http_request);
            
            -- Başarılı, durumu güncelle
            UPDATE public.whatsapp_queue
            SET 
                status = 'sent',
                sent_at = NOW(),
                response = response_data
            WHERE id = queue_item.id;
            
            RAISE NOTICE 'Mesaj gönderildi: %', queue_item.phone_number;
            
        EXCEPTION WHEN OTHERS THEN
            -- Hata durumunda durumu güncelle
            UPDATE public.whatsapp_queue
            SET 
                status = 'failed',
                error_message = SQLERRM,
                retry_count = retry_count + 1
            WHERE id = queue_item.id;
            
            RAISE NOTICE 'Mesaj gönderilemedi: % - Hata: %', queue_item.phone_number, SQLERRM;
        END;
    END LOOP;
END;
$$;

-- =====================================================
-- 2️⃣ UPDATE_WHATSAPP_PACKAGES_UPDATED_AT
-- =====================================================
CREATE OR REPLACE FUNCTION public.update_whatsapp_packages_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

-- Trigger'ı yeniden oluştur
DROP TRIGGER IF EXISTS trigger_update_whatsapp_packages_updated_at ON public.whatsapp_packages;
CREATE TRIGGER trigger_update_whatsapp_packages_updated_at
    BEFORE UPDATE ON public.whatsapp_packages
    FOR EACH ROW
    EXECUTE FUNCTION public.update_whatsapp_packages_updated_at();

-- =====================================================
-- 3️⃣ UPDATE_WHATSAPP_BALANCE
-- =====================================================
CREATE OR REPLACE FUNCTION public.update_whatsapp_balance(
    p_club_id TEXT,
    p_amount INTEGER,
    p_description TEXT,
    p_transaction_type TEXT DEFAULT 'debit'
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
    current_balance INTEGER;
    new_balance INTEGER;
    package_record RECORD;
BEGIN
    -- Mevcut bakiyeyi al
    SELECT balance INTO current_balance
    FROM public.whatsapp_packages
    WHERE club_id = p_club_id
    FOR UPDATE;
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Kulüp bulunamadı'
        );
    END IF;
    
    -- Yeni bakiyeyi hesapla
    IF p_transaction_type = 'debit' THEN
        new_balance := current_balance - p_amount;
        IF new_balance < 0 THEN
            RETURN jsonb_build_object(
                'success', false,
                'error', 'Yetersiz bakiye'
            );
        END IF;
    ELSE
        new_balance := current_balance + p_amount;
    END IF;
    
    -- Bakiyeyi güncelle
    UPDATE public.whatsapp_packages
    SET 
        balance = new_balance,
        updated_at = NOW()
    WHERE club_id = p_club_id;
    
    -- Transaction kaydı oluştur
    INSERT INTO public.whatsapp_transactions (
        club_id,
        transaction_type,
        amount,
        description,
        balance_before,
        balance_after,
        created_at
    ) VALUES (
        p_club_id,
        p_transaction_type,
        p_amount,
        p_description,
        current_balance,
        new_balance,
        NOW()
    );
    
    RETURN jsonb_build_object(
        'success', true,
        'balance_before', current_balance,
        'balance_after', new_balance
    );
END;
$$;

-- =====================================================
-- 4️⃣ CHECK_UPCOMING_PAYMENTS
-- =====================================================
CREATE OR REPLACE FUNCTION public.check_upcoming_payments()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
    member_record RECORD;
    days_until_due INTEGER;
    message_text TEXT;
    settings_data JSONB;
    template_text TEXT;
BEGIN
    -- Yaklaşan ödemeleri kontrol et (7 gün içinde)
    FOR member_record IN
        SELECT 
            m.*,
            b.lessonName as branch_name,
            b.clubId as club_id
        FROM public.members m
        LEFT JOIN public.branches b ON m.Sube = b.id
        WHERE 
            m.Uyelik_Durumu = 'Aktif'
            AND m.Son_Odeme_Tarihi IS NOT NULL
            AND m.Son_Odeme_Tarihi <= CURRENT_DATE + INTERVAL '7 days'
            AND m.Son_Odeme_Tarihi > CURRENT_DATE
            AND (m.Cep_Telefonu IS NOT NULL OR m.Baba_Cep_Telefonu IS NOT NULL OR m.Anne_Cep_Telefonu IS NOT NULL)
    LOOP
        days_until_due := (member_record.Son_Odeme_Tarihi - CURRENT_DATE);
        
        -- Mesaj şablonunu al
        SELECT data->'payment'->>'text' INTO template_text
        FROM public.settings
        WHERE id = 'messageTemplates_' || member_record.club_id;
        
        IF template_text IS NULL THEN
            template_text := 'Merhaba {ad}, {brans} üyeliğinizin ödeme tarihi {tarih} tarihinde dolacaktır. Lütfen ödemenizi zamanında yapınız.';
        END IF;
        
        -- Placeholder'ları değiştir
        message_text := REPLACE(template_text, '{ad}', COALESCE(member_record.Resit_Olmayan_Adi_Soyadi, member_record.Ad_Soyad, 'Değerli Üyemiz'));
        message_text := REPLACE(message_text, '{brans}', COALESCE(member_record.branch_name, 'Spor'));
        message_text := REPLACE(message_text, '{tarih}', TO_CHAR(member_record.Son_Odeme_Tarihi, 'DD.MM.YYYY'));
        message_text := REPLACE(message_text, '{gun}', days_until_due::TEXT);
        
        -- Kuyruğa ekle (anne, baba, öğrenci telefonlarına)
        IF member_record.Cep_Telefonu IS NOT NULL THEN
            INSERT INTO public.whatsapp_queue (club_id, phone_number, message_text, message_type, member_id, instance_name)
            VALUES (member_record.club_id, member_record.Cep_Telefonu, message_text, 'upcoming_payment', member_record.id, member_record.club_id);
        END IF;
        
        IF member_record.Baba_Cep_Telefonu IS NOT NULL AND member_record.Baba_Cep_Telefonu != member_record.Cep_Telefonu THEN
            INSERT INTO public.whatsapp_queue (club_id, phone_number, message_text, message_type, member_id, instance_name)
            VALUES (member_record.club_id, member_record.Baba_Cep_Telefonu, message_text, 'upcoming_payment', member_record.id, member_record.club_id);
        END IF;
        
        IF member_record.Anne_Cep_Telefonu IS NOT NULL AND member_record.Anne_Cep_Telefonu != member_record.Cep_Telefonu THEN
            INSERT INTO public.whatsapp_queue (club_id, phone_number, message_text, message_type, member_id, instance_name)
            VALUES (member_record.club_id, member_record.Anne_Cep_Telefonu, message_text, 'upcoming_payment', member_record.id, member_record.club_id);
        END IF;
        
        RAISE NOTICE 'Yaklaşan ödeme bildirimi oluşturuldu: % (% gün kaldı)', member_record.Ad_Soyad, days_until_due;
    END LOOP;
END;
$$;

-- =====================================================
-- 5️⃣ CHECK_OVERDUE_PAYMENTS
-- =====================================================
CREATE OR REPLACE FUNCTION public.check_overdue_payments()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
    member_record RECORD;
    days_overdue INTEGER;
    message_text TEXT;
    template_text TEXT;
BEGIN
    -- Gecikmiş ödemeleri kontrol et
    FOR member_record IN
        SELECT 
            m.*,
            b.lessonName as branch_name,
            b.clubId as club_id
        FROM public.members m
        LEFT JOIN public.branches b ON m.Sube = b.id
        WHERE 
            m.Uyelik_Durumu = 'Aktif'
            AND m.Son_Odeme_Tarihi IS NOT NULL
            AND m.Son_Odeme_Tarihi < CURRENT_DATE
            AND (m.Cep_Telefonu IS NOT NULL OR m.Baba_Cep_Telefonu IS NOT NULL OR m.Anne_Cep_Telefonu IS NOT NULL)
    LOOP
        days_overdue := (CURRENT_DATE - member_record.Son_Odeme_Tarihi);
        
        -- Mesaj şablonunu al
        SELECT data->'overduePayment'->>'text' INTO template_text
        FROM public.settings
        WHERE id = 'messageTemplates_' || member_record.club_id;
        
        IF template_text IS NULL THEN
            template_text := 'Sayın {ad}, {brans} üyeliğinizin ödemesi {gun} gündür gecikmiştir. Lütfen en kısa sürede ödemenizi yapınız.';
        END IF;
        
        -- Placeholder'ları değiştir
        message_text := REPLACE(template_text, '{ad}', COALESCE(member_record.Resit_Olmayan_Adi_Soyadi, member_record.Ad_Soyad, 'Değerli Üyemiz'));
        message_text := REPLACE(message_text, '{brans}', COALESCE(member_record.branch_name, 'Spor'));
        message_text := REPLACE(message_text, '{tarih}', TO_CHAR(member_record.Son_Odeme_Tarihi, 'DD.MM.YYYY'));
        message_text := REPLACE(message_text, '{gun}', days_overdue::TEXT);
        
        -- Kuyruğa ekle
        IF member_record.Cep_Telefonu IS NOT NULL THEN
            INSERT INTO public.whatsapp_queue (club_id, phone_number, message_text, message_type, member_id, instance_name)
            VALUES (member_record.club_id, member_record.Cep_Telefonu, message_text, 'overdue_payment', member_record.id, member_record.club_id);
        END IF;
        
        IF member_record.Baba_Cep_Telefonu IS NOT NULL AND member_record.Baba_Cep_Telefonu != member_record.Cep_Telefonu THEN
            INSERT INTO public.whatsapp_queue (club_id, phone_number, message_text, message_type, member_id, instance_name)
            VALUES (member_record.club_id, member_record.Baba_Cep_Telefonu, message_text, 'overdue_payment', member_record.id, member_record.club_id);
        END IF;
        
        IF member_record.Anne_Cep_Telefonu IS NOT NULL AND member_record.Anne_Cep_Telefonu != member_record.Cep_Telefonu THEN
            INSERT INTO public.whatsapp_queue (club_id, phone_number, message_text, message_type, member_id, instance_name)
            VALUES (member_record.club_id, member_record.Anne_Cep_Telefonu, message_text, 'overdue_payment', member_record.id, member_record.club_id);
        END IF;
        
        RAISE NOTICE 'Gecikmiş ödeme bildirimi oluşturuldu: % (% gün gecikmiş)', member_record.Ad_Soyad, days_overdue;
    END LOOP;
END;
$$;

-- =====================================================
-- 6️⃣ CHECK_TRIAL_REMINDERS
-- =====================================================
CREATE OR REPLACE FUNCTION public.check_trial_reminders()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
    member_record RECORD;
    message_text TEXT;
    template_text TEXT;
BEGIN
    -- Deneme süresi biten üyeleri kontrol et
    FOR member_record IN
        SELECT 
            m.*,
            b.lessonName as branch_name,
            b.clubId as club_id
        FROM public.members m
        LEFT JOIN public.branches b ON m.Sube = b.id
        WHERE 
            m.Uyelik_Durumu = 'Deneme'
            AND m.Deneme_Bitis_Tarihi IS NOT NULL
            AND m.Deneme_Bitis_Tarihi <= CURRENT_DATE + INTERVAL '2 days'
            AND m.Deneme_Bitis_Tarihi >= CURRENT_DATE
            AND (m.Cep_Telefonu IS NOT NULL OR m.Baba_Cep_Telefonu IS NOT NULL OR m.Anne_Cep_Telefonu IS NOT NULL)
    LOOP
        -- Mesaj şablonunu al
        SELECT data->'trial'->>'text' INTO template_text
        FROM public.settings
        WHERE id = 'messageTemplates_' || member_record.club_id;
        
        IF template_text IS NULL THEN
            template_text := 'Merhaba {ad}, {brans} deneme süreniz {tarih} tarihinde sona erecektir. Üyeliğinizi devam ettirmek için lütfen bizimle iletişime geçin.';
        END IF;
        
        -- Placeholder'ları değiştir
        message_text := REPLACE(template_text, '{ad}', COALESCE(member_record.Resit_Olmayan_Adi_Soyadi, member_record.Ad_Soyad, 'Değerli Üyemiz'));
        message_text := REPLACE(message_text, '{brans}', COALESCE(member_record.branch_name, 'Spor'));
        message_text := REPLACE(message_text, '{tarih}', TO_CHAR(member_record.Deneme_Bitis_Tarihi, 'DD.MM.YYYY'));
        
        -- Kuyruğa ekle
        IF member_record.Cep_Telefonu IS NOT NULL THEN
            INSERT INTO public.whatsapp_queue (club_id, phone_number, message_text, message_type, member_id, instance_name)
            VALUES (member_record.club_id, member_record.Cep_Telefonu, message_text, 'trial_reminder', member_record.id, member_record.club_id);
        END IF;
        
        IF member_record.Baba_Cep_Telefonu IS NOT NULL AND member_record.Baba_Cep_Telefonu != member_record.Cep_Telefonu THEN
            INSERT INTO public.whatsapp_queue (club_id, phone_number, message_text, message_type, member_id, instance_name)
            VALUES (member_record.club_id, member_record.Baba_Cep_Telefonu, message_text, 'trial_reminder', member_record.id, member_record.club_id);
        END IF;
        
        IF member_record.Anne_Cep_Telefonu IS NOT NULL AND member_record.Anne_Cep_Telefonu != member_record.Cep_Telefonu THEN
            INSERT INTO public.whatsapp_queue (club_id, phone_number, message_text, message_type, member_id, instance_name)
            VALUES (member_record.club_id, member_record.Anne_Cep_Telefonu, message_text, 'trial_reminder', member_record.id, member_record.club_id);
        END IF;
        
        RAISE NOTICE 'Deneme süresi hatırlatması oluşturuldu: %', member_record.Ad_Soyad;
    END LOOP;
END;
$$;

-- ✅ BAŞARILI MESAJI
DO $$
BEGIN
    RAISE NOTICE '✅ Tüm fonksiyonlar güvenlik uyarıları düzeltilerek güncellendi!';
    RAISE NOTICE '   - send_whatsapp_from_queue';
    RAISE NOTICE '   - update_whatsapp_packages_updated_at';
    RAISE NOTICE '   - update_whatsapp_balance';
    RAISE NOTICE '   - check_upcoming_payments';
    RAISE NOTICE '   - check_overdue_payments';
    RAISE NOTICE '   - check_trial_reminders';
    RAISE NOTICE '';
    RAISE NOTICE '📋 Supabase SQL Editor''da çalıştırın:';
    RAISE NOTICE '   1. Supabase Dashboard > SQL Editor açın';
    RAISE NOTICE '   2. Bu dosyayı (fix-function-security-warnings.sql) yapıştırın';
    RAISE NOTICE '   3. "Run" butonuna tıklayın';
    RAISE NOTICE '';
    RAISE NOTICE '🔒 Eklenen güvenlik ayarları:';
    RAISE NOTICE '   - SECURITY DEFINER (fonksiyon sahibinin yetkisiyle çalışır)';
    RAISE NOTICE '   - SET search_path = '''' (güvenlik açığını kapatır)';
END $$;
