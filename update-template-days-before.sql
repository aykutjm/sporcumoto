-- Deneme Dersi için days_before = 0 (aynı gün)
UPDATE message_templates
SET days_before = 0
WHERE category = 'trial_lesson';

-- Yaklaşan Ödeme için days_before = 2
UPDATE message_templates
SET days_before = 2
WHERE category = 'upcoming_payment';

-- Kontrol: Tüm kulüplerin güncel değerleri
SELECT 
  c.name as club_name,
  mt.template_name,
  mt.category,
  mt.send_days,
  mt.send_time,
  mt.days_before,
  mt.is_active
FROM message_templates mt
JOIN clubs c ON c.id = mt.club_id
ORDER BY c.name, mt.category;
