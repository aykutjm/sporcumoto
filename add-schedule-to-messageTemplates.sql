-- message_templates tablosuna gün ve saat planlaması için kolonlar ekle

-- Mesajın gönderileceği günler (0-6: Pazar-Cumartesi)
ALTER TABLE message_templates 
ADD COLUMN IF NOT EXISTS send_days integer[] DEFAULT '{1,2,3,4,5}';

-- Mesajın gönderileceği saat (HH:MM formatında)
ALTER TABLE message_templates 
ADD COLUMN IF NOT EXISTS send_time time DEFAULT '09:00:00';

COMMENT ON COLUMN message_templates.send_days IS 'Mesajın gönderileceği günler (0=Pazar, 1=Pazartesi, ..., 6=Cumartesi)';
COMMENT ON COLUMN message_templates.send_time IS 'Mesajın gönderileceği saat (HH:MM:SS formatında)';
