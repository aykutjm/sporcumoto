-- Atakum'un cihazlarının message_sending_hours değerlerini göster
SELECT 
  wd.id,
  wd."instanceName",
  wd."phoneNumber",
  wd.message_sending_hours
FROM "whatsappDevices" wd
WHERE wd."clubId" = (SELECT id FROM clubs WHERE name ILIKE '%atakum%' LIMIT 1);

-- Eğer mesaj gönderim saatleri settings tablosunda tutuluyorsa:
SELECT 
  s."clubId",
  c.name,
  s.data->'messageSendingHours' as message_sending_hours_from_settings
FROM settings s
JOIN clubs c ON c.id = s."clubId"
WHERE c.name ILIKE '%atakum%'
LIMIT 1;
