-- message_templates tablosuna mesai saatleri kolonları ekle
ALTER TABLE message_templates
ADD COLUMN working_hours_enabled boolean DEFAULT true,
ADD COLUMN working_hours_start time DEFAULT '09:00',
ADD COLUMN working_hours_end time DEFAULT '18:00',
ADD COLUMN working_days integer[] DEFAULT ARRAY[1,2,3,4,5]; -- Pazartesi-Cuma

-- Mevcut kayıtlara default değerler ata
UPDATE message_templates
SET 
  working_hours_enabled = true,
  working_hours_start = '09:00',
  working_hours_end = '18:00',
  working_days = ARRAY[1,2,3,4,5]
WHERE working_hours_enabled IS NULL;

-- Kontrol et
SELECT 
  template_name,
  category,
  working_hours_enabled,
  working_hours_start,
  working_hours_end,
  working_days
FROM message_templates
WHERE club_id = (SELECT id FROM clubs WHERE name ILIKE '%atakum%' LIMIT 1)
ORDER BY category;
