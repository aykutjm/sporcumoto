-- Tüm kulüplerin cihazlarındaki message_sending_hours değerlerini göster
SELECT 
  c.name as club_name,
  wd."instanceName",
  wd.message_sending_hours
FROM "whatsappDevices" wd
JOIN clubs c ON c.id = wd."clubId"
ORDER BY c.name
LIMIT 10;
