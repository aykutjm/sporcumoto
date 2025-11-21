-- ADIM 4: Cron Job'ları Kur

-- 1. Yaklaşan Ödemeler (Her 5 dakikada bir kontrol et)
SELECT cron.schedule(
    'check-upcoming-payments',
    '*/5 * * * *',
    $$SELECT public.check_upcoming_payments()$$
);

-- 2. Gecikmiş Ödemeler (Her 5 dakikada bir kontrol et)
SELECT cron.schedule(
    'check-overdue-payments',
    '*/5 * * * *',
    $$SELECT public.check_overdue_payments()$$
);

-- 3. Deneme Dersi Hatırlatmaları (Her 5 dakikada bir kontrol et)
SELECT cron.schedule(
    'check-trial-reminders',
    '*/5 * * * *',
    $$SELECT public.check_trial_reminders()$$
);

-- Cron Job'ları Kontrol Et
SELECT * FROM cron.job WHERE active = true;
