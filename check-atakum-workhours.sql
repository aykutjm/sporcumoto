-- Atakum Tenis'in çalışma saatleri
SELECT 
  c.name as club_name,
  s."workingHoursEnabled",
  s."workingHoursStart",
  s."workingHoursEnd",
  s."workingDays"
FROM settings s
JOIN clubs c ON c.id = s."clubId"
WHERE c.name ILIKE '%atakum%'
LIMIT 1;
