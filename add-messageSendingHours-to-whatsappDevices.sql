-- whatsapp_devices tablosuna message_sending_hours kolonu ekle

ALTER TABLE whatsapp_devices 
ADD COLUMN IF NOT EXISTS message_sending_hours jsonb DEFAULT '{
  "enabled": true,
  "days": [1,2,3,4,5],
  "start": "09:00",
  "end": "18:00"
}'::jsonb;

COMMENT ON COLUMN whatsapp_devices.message_sending_hours IS 'Mesaj gönderim saatleri (enabled, days, start, end)';

-- Kontrol
SELECT 
  device_name,
  phone_number,
  message_sending_hours
FROM whatsapp_devices
LIMIT 5;
