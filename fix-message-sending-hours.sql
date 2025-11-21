-- message_templates tablosundan mesaj gönderim saatleri kolonlarını kaldır
ALTER TABLE message_templates
DROP COLUMN IF EXISTS message_send_hours_start,
DROP COLUMN IF EXISTS message_send_hours_end,
DROP COLUMN IF EXISTS message_send_days;

-- whatsappDevices tablosuna mesaj gönderim çalışma saatleri ekle
ALTER TABLE "whatsappDevices"
ADD COLUMN IF NOT EXISTS message_sending_hours jsonb 
DEFAULT '{"enabled":true,"days":[1,2,3,4,5],"start":"09:00","end":"18:00"}';

-- Mevcut cihazlara default değer ata
UPDATE "whatsappDevices"
SET message_sending_hours = '{"enabled":true,"days":[1,2,3,4,5],"start":"09:00","end":"18:00"}'
WHERE message_sending_hours IS NULL;

-- Kontrol: Atakum'un cihaz ayarlarını göster
SELECT 
  wd.id,
  wd."deviceName",
  wd."phoneNumber",
  wd.message_sending_hours,
  c.name as club_name
FROM "whatsappDevices" wd
JOIN clubs c ON c.id = wd."clubId"
WHERE c.name ILIKE '%atakum%'
LIMIT 5;
