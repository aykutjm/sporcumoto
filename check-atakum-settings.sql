-- Atakum Tenis'in ayarlarını kontrol et
SELECT 
  s."clubId",
  c.name as club_name,
  s."workingHoursEnabled",
  s."workingHoursStart",
  s."workingHoursEnd",
  s."workingDays",
  s."trialReminderSettings"
FROM settings s
JOIN clubs c ON c.id = s."clubId"
WHERE c.name ILIKE '%atakum%'
LIMIT 1;

-- Atakum Tenis'in şablonlarını kontrol et
SELECT 
  mt.id,
  mt.template_name,
  mt.category,
  mt.send_days,
  mt.send_time,
  mt.days_before,
  mt.is_active
FROM message_templates mt
JOIN clubs c ON c.id = mt.club_id
WHERE c.name ILIKE '%atakum%'
ORDER BY mt.category;
