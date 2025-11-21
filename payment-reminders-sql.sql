-- 💰 ÖDEME HATIRLATICLARI - 7/24 ARKA PLAN SİSTEMİ
-- Supabase SQL fonksiyonları ile site kapalıyken bile çalışır

-- ============================================
-- 1️⃣ YAKLAŞAN ÖDEME HATIRLATICLARI
-- ============================================

CREATE OR REPLACE FUNCTION public.check_upcoming_payments()
RETURNS json AS $$
DECLARE
    settings_record RECORD;
    member_record RECORD;
    prereg_record RECORD;
    payment_item jsonb;
    branch_key text;
    branch_templates jsonb;
    template_config jsonb;
    days_before int;
    send_time text;
    current_time text;
    scheduled_datetime timestamp;
    reminder_date date;
    message_text text;
    member_name text;
    student_name text;
    payment_date date;
    payment_amount numeric;
    days_left int;
    success_count int := 0;
    total_count int := 0;
    already_sent boolean;
BEGIN
    -- Şu anki saat (HH:MM formatında)
    current_time := TO_CHAR(NOW(), 'HH24:MI');
    
    -- Settings tablosundan messageTemplates al
    FOR settings_record IN
        SELECT * FROM settings WHERE id LIKE 'messageTemplates_%'
    LOOP
        -- Her kulübün her branşını kontrol et
        FOR branch_key IN SELECT jsonb_object_keys(settings_record.data::jsonb)
        LOOP
            -- Branş şablonlarını al (tenis, yuzme, etc.)
            IF branch_key NOT IN ('updatedAt', 'updatedBy', 'task', 'taskReminder', 'taskMessage') THEN
                branch_templates := settings_record.data::jsonb -> branch_key;
                template_config := branch_templates -> 'upcomingPayment';
                
                -- Şablon etkin mi kontrol et
                IF (template_config ->> 'enabled')::boolean = true THEN
                    days_before := COALESCE((template_config ->> 'daysBefore')::int, 2);
                    send_time := COALESCE(template_config ->> 'sendTime', '10:00');
                    
                    -- Şu anki saat, send_time ile eşleşiyor mu? (±5 dakika tolerans)
                    IF current_time BETWEEN 
                        TO_CHAR((send_time::time - INTERVAL '5 minutes')::time, 'HH24:MI') AND 
                        TO_CHAR((send_time::time + INTERVAL '5 minutes')::time, 'HH24:MI') THEN
                        
                        -- Bu branştaki üyeleri kontrol et
                        FOR member_record IN
                            SELECT * FROM members 
                            WHERE "clubId" = settings_record."clubId"
                            AND LOWER("Brans") = branch_key
                            AND status = 'active'
                            AND "Telefon" IS NOT NULL
                        LOOP
                            -- Üyenin preRegistration kaydını bul
                            SELECT * INTO prereg_record FROM "preRegistrations"
                            WHERE id = member_record."preRegId";
                            
                            IF prereg_record.id IS NOT NULL AND prereg_record."paymentSchedule" IS NOT NULL THEN
                                -- Her payment'ı kontrol et
                                FOR payment_item IN SELECT * FROM jsonb_array_elements(prereg_record."paymentSchedule"::jsonb)
                                LOOP
                                    payment_date := (payment_item ->> 'dueDate')::date;
                                    reminder_date := payment_date - (days_before || ' days')::interval;
                                    
                                    -- Bugün hatırlatma günü mü?
                                    IF reminder_date::date = CURRENT_DATE AND (payment_item ->> 'paid')::boolean = false THEN
                                        total_count := total_count + 1;
                                        
                                        -- Bugün bu üyeye zaten mesaj gönderilmiş mi kontrol et
                                        SELECT EXISTS(
                                            SELECT 1 FROM "whatsappMessages"
                                            WHERE "toNumber" = member_record."Telefon"
                                            AND DATE("sentAt") = CURRENT_DATE
                                            AND "messageText" LIKE '%yaklaşan%ödeme%'
                                        ) INTO already_sent;
                                        
                                        IF NOT already_sent THEN
                                            -- Mesaj metnini hazırla
                                            IF member_record."Resit_Olmayan_Adi_Soyadi" IS NOT NULL THEN
                                                message_text := template_config ->> 'textChild';
                                                member_name := member_record."Ad_Soyad";
                                                student_name := member_record."Resit_Olmayan_Adi_Soyadi";
                                            ELSE
                                                message_text := template_config ->> 'textAdult';
                                                member_name := member_record."Ad_Soyad";
                                                student_name := '';
                                            END IF;
                                            
                                            payment_amount := (payment_item ->> 'amount')::numeric;
                                            days_left := (payment_date - CURRENT_DATE)::int;
                                            
                                            -- Placeholder'ları değiştir
                                            message_text := REPLACE(message_text, '{UYE_AD_SOYAD}', member_name);
                                            message_text := REPLACE(message_text, '{OGRENCI_AD_SOYAD}', student_name);
                                            message_text := REPLACE(message_text, '{TUTAR}', payment_amount::text);
                                            message_text := REPLACE(message_text, '{TARIH}', TO_CHAR(payment_date, 'DD.MM.YYYY'));
                                            message_text := REPLACE(message_text, '{GUN_KALDI}', days_left::text);
                                            message_text := REPLACE(message_text, '{DONEM_BASLANGIC}', TO_CHAR((payment_item ->> 'period.start')::date, 'DD.MM.YYYY'));
                                            message_text := REPLACE(message_text, '{DONEM_BITIS}', TO_CHAR((payment_item ->> 'period.end')::date, 'DD.MM.YYYY'));
                                            message_text := REPLACE(message_text, '{DERS_SAYISI}', (payment_item ->> 'lessonCount')::text);
                                            
                                            -- Gönderim zamanını hesapla (bugün, şablondaki saat)
                                            scheduled_datetime := CURRENT_DATE + send_time::time;
                                            
                                            -- Mesajı kuyruğa ekle
                                            INSERT INTO "messageQueue" (
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
                                                'msg_' || gen_random_uuid()::text,
                                                settings_record."clubId",
                                                member_record."Telefon",
                                                message_text,
                                                member_record."deviceId",
                                                member_name,
                                                'pending',
                                                scheduled_datetime,
                                                NOW()
                                            ) ON CONFLICT DO NOTHING;
                                            
                                            success_count := success_count + 1;
                                        END IF;
                                    END IF;
                                END LOOP;
                            END IF;
                        END LOOP;
                    END IF;
                END IF;
            END IF;
        END LOOP;
    END LOOP;
    
    RETURN json_build_object(
        'success', true,
        'type', 'upcomingPayments',
        'current_time', current_time,
        'total_checked', total_count,
        'queued', success_count,
        'processed_at', NOW()
    );
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 2️⃣ GECİKMİŞ ÖDEME HATIRLATICLARI
-- ============================================

CREATE OR REPLACE FUNCTION public.check_overdue_payments()
RETURNS json AS $$
DECLARE
    settings_record RECORD;
    member_record RECORD;
    prereg_record RECORD;
    payment_item jsonb;
    branch_key text;
    branch_templates jsonb;
    template_config jsonb;
    days_after int;
    send_time text;
    current_time text;
    scheduled_datetime timestamp;
    reminder_date date;
    message_text text;
    member_name text;
    student_name text;
    payment_date date;
    payment_amount numeric;
    days_overdue int;
    success_count int := 0;
    total_count int := 0;
    already_sent boolean;
BEGIN
    -- Şu anki saat (HH:MM formatında)
    current_time := TO_CHAR(NOW(), 'HH24:MI');
    
    -- Settings tablosundan messageTemplates al
    FOR settings_record IN
        SELECT * FROM settings WHERE id LIKE 'messageTemplates_%'
    LOOP
        -- Her kulübün her branşını kontrol et
        FOR branch_key IN SELECT jsonb_object_keys(settings_record.data::jsonb)
        LOOP
            -- Branş şablonlarını al
            IF branch_key NOT IN ('updatedAt', 'updatedBy', 'task', 'taskReminder', 'taskMessage') THEN
                branch_templates := settings_record.data::jsonb -> branch_key;
                template_config := branch_templates -> 'payment';
                
                -- Şablon etkin mi kontrol et
                IF (template_config ->> 'enabled')::boolean = true THEN
                    days_after := COALESCE((template_config ->> 'daysAfter')::int, 2);
                    send_time := COALESCE(template_config ->> 'sendTime', '14:00');
                    
                    -- Şu anki saat, send_time ile eşleşiyor mu? (±5 dakika tolerans)
                    IF current_time BETWEEN 
                        TO_CHAR((send_time::time - INTERVAL '5 minutes')::time, 'HH24:MI') AND 
                        TO_CHAR((send_time::time + INTERVAL '5 minutes')::time, 'HH24:MI') THEN
                        
                        -- Bu branştaki üyeleri kontrol et
                        FOR member_record IN
                            SELECT * FROM members 
                            WHERE "clubId" = settings_record."clubId"
                            AND LOWER("Brans") = branch_key
                            AND status = 'active'
                            AND "Telefon" IS NOT NULL
                        LOOP
                            -- Üyenin preRegistration kaydını bul
                            SELECT * INTO prereg_record FROM "preRegistrations"
                            WHERE id = member_record."preRegId";
                            
                            IF prereg_record.id IS NOT NULL AND prereg_record."paymentSchedule" IS NOT NULL THEN
                                -- Her payment'ı kontrol et
                                FOR payment_item IN SELECT * FROM jsonb_array_elements(prereg_record."paymentSchedule"::jsonb)
                                LOOP
                                    payment_date := (payment_item ->> 'dueDate')::date;
                                    reminder_date := payment_date + (days_after || ' days')::interval;
                                    
                                    -- Bugün hatırlatma günü mü VE ödeme yapılmamış mı?
                                    IF reminder_date::date = CURRENT_DATE AND (payment_item ->> 'paid')::boolean = false THEN
                                        total_count := total_count + 1;
                                        
                                        -- Bugün bu üyeye zaten mesaj gönderilmiş mi kontrol et
                                        SELECT EXISTS(
                                            SELECT 1 FROM "whatsappMessages"
                                            WHERE "toNumber" = member_record."Telefon"
                                            AND DATE("sentAt") = CURRENT_DATE
                                            AND "messageText" LIKE '%gecikmiş%ödeme%'
                                        ) INTO already_sent;
                                        
                                        IF NOT already_sent THEN
                                            -- Mesaj metnini hazırla
                                            IF member_record."Resit_Olmayan_Adi_Soyadi" IS NOT NULL THEN
                                                message_text := template_config ->> 'textChild';
                                                member_name := member_record."Ad_Soyad";
                                                student_name := member_record."Resit_Olmayan_Adi_Soyadi";
                                            ELSE
                                                message_text := template_config ->> 'textAdult';
                                                member_name := member_record."Ad_Soyad";
                                                student_name := '';
                                            END IF;
                                            
                                            payment_amount := (payment_item ->> 'amount')::numeric;
                                            days_overdue := (CURRENT_DATE - payment_date)::int;
                                            
                                            -- Placeholder'ları değiştir
                                            message_text := REPLACE(message_text, '{UYE_AD_SOYAD}', member_name);
                                            message_text := REPLACE(message_text, '{OGRENCI_AD_SOYAD}', student_name);
                                            message_text := REPLACE(message_text, '{TUTAR}', payment_amount::text);
                                            message_text := REPLACE(message_text, '{TARIH}', TO_CHAR(payment_date, 'DD.MM.YYYY'));
                                            message_text := REPLACE(message_text, '{DONEM_BASLANGIC}', TO_CHAR((payment_item ->> 'period.start')::date, 'DD.MM.YYYY'));
                                            message_text := REPLACE(message_text, '{DONEM_BITIS}', TO_CHAR((payment_item ->> 'period.end')::date, 'DD.MM.YYYY'));
                                            message_text := REPLACE(message_text, '{DERS_SAYISI}', (payment_item ->> 'lessonCount')::text);
                                            
                                            -- Gönderim zamanını hesapla (bugün, şablondaki saat)
                                            scheduled_datetime := CURRENT_DATE + send_time::time;
                                            
                                            -- Mesajı kuyruğa ekle
                                            INSERT INTO "messageQueue" (
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
                                                'msg_' || gen_random_uuid()::text,
                                                settings_record."clubId",
                                                member_record."Telefon",
                                                message_text,
                                                member_record."deviceId",
                                                member_name,
                                                'pending',
                                                scheduled_datetime,
                                                NOW()
                                            ) ON CONFLICT DO NOTHING;
                                            
                                            success_count := success_count + 1;
                                        END IF;
                                    END IF;
                                END LOOP;
                            END IF;
                        END LOOP;
                    END IF;
                END IF;
            END IF;
        END LOOP;
    END LOOP;
    
    RETURN json_build_object(
        'success', true,
        'type', 'overduePayments',
        'current_time', current_time,
        'total_checked', total_count,
        'queued', success_count,
        'processed_at', NOW()
    );
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 3️⃣ DENEME DERSİ HATIRLATICLARI
-- ============================================

CREATE OR REPLACE FUNCTION public.check_trial_reminders()
RETURNS json AS $$
DECLARE
    settings_record RECORD;
    member_record RECORD;
    branch_key text;
    branch_templates jsonb;
    template_config jsonb;
    send_time text;
    current_time text;
    scheduled_datetime timestamp;
    message_text text;
    member_name text;
    student_name text;
    success_count int := 0;
    total_count int := 0;
    already_sent boolean;
BEGIN
    -- Şu anki saat (HH:MM formatında)
    current_time := TO_CHAR(NOW(), 'HH24:MI');
    
    -- Settings tablosundan messageTemplates al
    FOR settings_record IN
        SELECT * FROM settings WHERE id LIKE 'messageTemplates_%'
    LOOP
        -- Her kulübün her branşını kontrol et
        FOR branch_key IN SELECT jsonb_object_keys(settings_record.data::jsonb)
        LOOP
            -- Branş şablonlarını al
            IF branch_key NOT IN ('updatedAt', 'updatedBy', 'task', 'taskReminder', 'taskMessage') THEN
                branch_templates := settings_record.data::jsonb -> branch_key;
                template_config := branch_templates -> 'trialReminder';
                
                -- Şablon etkin mi kontrol et
                IF (template_config ->> 'enabled')::boolean = true THEN
                    send_time := COALESCE(template_config ->> 'sendTime', '09:00');
                    
                    -- Bugün deneme dersi olan üyeleri kontrol et
                    FOR member_record IN
                        SELECT * FROM members 
                        WHERE "clubId" = settings_record."clubId"
                        AND LOWER("Brans") = branch_key
                        AND status = 'trial'  -- veya deneme dersi flag'i
                        AND "Telefon" IS NOT NULL
                        -- AND trial_date::date = CURRENT_DATE
                    LOOP
                        total_count := total_count + 1;
                        
                        -- Mesaj metnini hazırla
                        IF member_record."Resit_Olmayan_Adi_Soyadi" IS NOT NULL THEN
                            message_text := template_config ->> 'textChild';
                            member_name := member_record."Ad_Soyad";
                            student_name := member_record."Resit_Olmayan_Adi_Soyadi";
                        ELSE
                            message_text := template_config ->> 'textAdult';
                            member_name := member_record."Ad_Soyad";
                            student_name := '';
                        END IF;
                        
                        -- Placeholder'ları değiştir
                        message_text := REPLACE(message_text, '{UYE_AD_SOYAD}', member_name);
                        message_text := REPLACE(message_text, '{OGRENCI_AD_SOYAD}', student_name);
                        -- {TARIH}, {SAAT}, {ADRES}, {KULUP_ADI}
                        
                        -- Gönderim zamanını hesapla (bugün, belirtilen saat)
                        scheduled_datetime := CURRENT_DATE + send_time::time;
                        
                        -- Mesajı kuyruğa ekle
                        -- INSERT INTO "messageQueue" (...) VALUES (...);
                        
                        success_count := success_count + 1;
                    END LOOP;
                END IF;
            END IF;
        END LOOP;
    END LOOP;
    
    RETURN json_build_object(
        'success', true,
        'type', 'trialReminders',
        'total_checked', total_count,
        'queued', success_count,
        'processed_at', NOW()
    );
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 4️⃣ CRON JOB'LARI EKLE
-- ============================================

-- ⏰ HER 5 DAKİKADA BİR ÇALIŞ
-- Şablonlardaki saatlere göre mesaj gönderir
-- Örnek: upcomingPayment sendTime: 10:00 ise, 10:00-10:05 arasında çalışır

-- Yaklaşan ödemeleri kontrol et (her 5 dakikada)
SELECT cron.schedule(
    'check-upcoming-payments',
    '*/5 * * * *',  -- Her 5 dakikada bir
    $$SELECT public.check_upcoming_payments();$$
);

-- Gecikmiş ödemeleri kontrol et (her 5 dakikada)
SELECT cron.schedule(
    'check-overdue-payments',
    '*/5 * * * *',  -- Her 5 dakikada bir
    $$SELECT public.check_overdue_payments();$$
);

-- Deneme dersi hatırlatmalarını kontrol et (her 5 dakikada)
SELECT cron.schedule(
    'check-trial-reminders',
    '*/5 * * * *',  -- Her 5 dakikada bir
    $$SELECT public.check_trial_reminders();$$
);

-- ============================================
-- 📋 MANUEL TEST KOMUTLARI
-- ============================================

-- Yaklaşan ödemeleri test et
-- SELECT public.check_upcoming_payments();

-- Gecikmiş ödemeleri test et
-- SELECT public.check_overdue_payments();

-- Deneme dersi hatırlatmalarını test et
-- SELECT public.check_trial_reminders();

-- Aktif cron job'ları kontrol et
-- SELECT * FROM cron.job WHERE active = true;

-- ============================================
-- ⚠️ ÖNEMLİ NOTLAR
-- ============================================

-- 1. payments TABLOSU: Şu anda members tablosunda ödeme bilgileri var mı?
--    Yoksa ayrı bir payments tablosu oluşturulmalı.
--
-- 2. PLACEHOLDER DEĞİŞTİRME: {TUTAR}, {TARIH}, {DONEM_BASLANGIC} gibi
--    değişkenler gerçek verilerle değiştirilmeli.
--
-- 3. KUYRUK EKLEME: messageQueue'ya INSERT işlemleri tamamlanmalı.
--    - phone, message, scheduledFor, deviceId, recipientName, clubId
--
-- 4. TEKRAR GÖNDERME KONTROLÜ: Aynı kişiye bugün zaten mesaj gönderildiyse
--    tekrar gönderme (whatsappMessages tablosunu kontrol et).
