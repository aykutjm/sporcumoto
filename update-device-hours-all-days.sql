-- Tüm cihazların mesaj gönderim saatlerini HER GÜN olarak güncelle
UPDATE "whatsappDevices"
SET message_sending_hours = jsonb_set(
  message_sending_hours,
  '{days}',
  '[0,1,2,3,4,5,6]'::jsonb
)
WHERE message_sending_hours IS NOT NULL;

-- Kontrol: Güncellenmiş değerleri göster
SELECT 
  c.name as club_name,
  wd."instanceName",
  wd.message_sending_hours
FROM "whatsappDevices" wd
JOIN clubs c ON c.id = wd."clubId"
ORDER BY c.name
LIMIT 5;
