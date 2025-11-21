-- settings tablosundan otomatik mesaj ayarlarını kontrol et
SELECT 
  c.name as club_name,
  s.data->'autoReplySettings' as auto_reply_settings,
  s.data->'messageSendingHours' as message_sending_hours
FROM settings s
JOIN clubs c ON c.id = s."clubId"
ORDER BY s."updatedAt" DESC
LIMIT 5;
