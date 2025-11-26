-- Tüm kulüplerin cihazlarını ve mesaj gönderim saatlerini göster
SELECT 
  c.name as club_name,
  wd."instanceName",
  wd."phoneNumber",
  wd.status,
  wd.message_sending_hours,
  wd."createdAt"
FROM "whatsappDevices" wd
JOIN clubs c ON c.id = wd."clubId"
ORDER BY c.name, wd."createdAt" DESC;
