-- Mevcut şablonları güncelle (Aktif/Pasif durumlarını düzelt)

-- Devamsızlık → Aktif
UPDATE message_templates 
SET is_active = true
WHERE category = 'absence';

-- Yaklaşan Ödemeler → Aktif, 2 gün önceden
UPDATE message_templates 
SET is_active = true, days_before = 2
WHERE category = 'upcoming_payment';

-- Deneme Dersi → Aktif
UPDATE message_templates 
SET is_active = true
WHERE category = 'trial_lesson';

-- Kontrol
SELECT 
  c.name as club_name,
  mt.template_name,
  mt.category,
  mt.is_active,
  mt.send_days,
  mt.send_time,
  mt.days_before
FROM message_templates mt
JOIN clubs c ON c.id = mt.club_id
ORDER BY c.name, mt.category;
