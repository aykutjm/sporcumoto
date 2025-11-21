-- ================================
-- TEST KOMUTLARI
-- ================================

-- 1️⃣ MANUEL TEST: Fonksiyonları tek tek çalıştır
-- ================================

-- Yaklaşan ödemeleri kontrol et
SELECT public.check_upcoming_payments();

-- Gecikmiş ödemeleri kontrol et
SELECT public.check_overdue_payments();

-- Deneme dersi hatırlatmalarını kontrol et
SELECT public.check_trial_reminders();


-- 2️⃣ SONUÇLARI KONTROL ET
-- ================================

-- Kuyruğa eklenen mesajları gör
SELECT 
    id,
    phone,
    "recipientName",
    LEFT(message, 50) as message_preview,
    status,
    "scheduledFor",
    "createdAt"
FROM "messageQueue"
WHERE DATE("createdAt") = CURRENT_DATE
ORDER BY "createdAt" DESC
LIMIT 20;


-- 3️⃣ CRON JOB'LARI KONTROL ET
-- ================================

-- Aktif cron job'ları listele
SELECT 
    jobid,
    jobname,
    schedule,
    active,
    command
FROM cron.job
WHERE active = true;

-- Cron job geçmişini kontrol et (son 10)
SELECT 
    jobid,
    runid,
    job_pid,
    status,
    start_time,
    end_time
FROM cron.job_run_details
ORDER BY start_time DESC
LIMIT 10;


-- 4️⃣ MESAJ ŞABLONLARINI KONTROL ET
-- ================================

-- Tenis branşı için ayarları gör
SELECT 
    id,
    "clubId",
    data::jsonb -> 'tenis' -> 'upcomingPayment' as upcoming_payment_config,
    data::jsonb -> 'tenis' -> 'payment' as overdue_payment_config,
    data::jsonb -> 'tenis' -> 'trialReminder' as trial_reminder_config
FROM settings
WHERE id LIKE 'messageTemplates_%';


-- 5️⃣ TEST VERİSİ OLUŞTURMA (İHTİYAÇ HALİNDE)
-- ================================

-- Yaklaşan ödeme testi için: 2 gün sonra ödeme tarihi olan kayıt ekle
-- NOT: Bu sadece örnek, gerçek veri yapınıza göre düzenleyin

/*
UPDATE "preRegistrations"
SET "paymentSchedule" = jsonb_set(
    COALESCE("paymentSchedule", '[]'::jsonb),
    '{0}',
    jsonb_build_object(
        'dueDate', (CURRENT_DATE + INTERVAL '2 days')::text,
        'amount', 500,
        'paid', false,
        'period', 'Kasım 2024'
    )
)
WHERE id = 'TEST_PREREG_ID';
*/


-- 6️⃣ ZAMANLAMAYI TEST ET
-- ================================

-- Şu anki saat ile şablon saatini karşılaştır
SELECT 
    TO_CHAR(NOW(), 'HH24:MI') as current_time,
    '10:00'::time as upcoming_payment_time,
    '14:00'::time as overdue_payment_time,
    '09:00'::time as trial_reminder_time,
    CASE 
        WHEN TO_CHAR(NOW(), 'HH24:MI') BETWEEN 
            TO_CHAR(('10:00'::time - INTERVAL '5 minutes')::time, 'HH24:MI') AND 
            TO_CHAR(('10:00'::time + INTERVAL '5 minutes')::time, 'HH24:MI')
        THEN 'Yaklaşan Ödeme Çalışır ✅'
        ELSE 'Yaklaşan Ödeme Çalışmaz ⏸️'
    END as upcoming_status,
    CASE 
        WHEN TO_CHAR(NOW(), 'HH24:MI') BETWEEN 
            TO_CHAR(('14:00'::time - INTERVAL '5 minutes')::time, 'HH24:MI') AND 
            TO_CHAR(('14:00'::time + INTERVAL '5 minutes')::time, 'HH24:MI')
        THEN 'Gecikmiş Ödeme Çalışır ✅'
        ELSE 'Gecikmiş Ödeme Çalışmaz ⏸️'
    END as overdue_status;


-- 7️⃣ HATA AYIKLAMA
-- ================================

-- Bugün gönderilen WhatsApp mesajlarını kontrol et
SELECT 
    id,
    "toNumber",
    LEFT("messageText", 100) as message,
    "sentAt",
    status
FROM "whatsappMessages"
WHERE DATE("sentAt") = CURRENT_DATE
ORDER BY "sentAt" DESC;

-- Aktif üyeleri kontrol et
SELECT 
    COUNT(*) as total_active_members,
    "Brans"
FROM members
WHERE status = 'active'
GROUP BY "Brans";

-- Bekleyen ön kayıtları kontrol et
SELECT 
    COUNT(*) as total_pending,
    branch,
    COUNT(CASE WHEN "lessonDate" IS NOT NULL THEN 1 END) as with_lesson_date
FROM "preRegistrations"
WHERE status = 'pending'
GROUP BY branch;
