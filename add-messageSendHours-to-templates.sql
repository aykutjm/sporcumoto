-- message_templates tablosuna mesaj gönderim süreleri kolonları ekle
ALTER TABLE message_templates
ADD COLUMN IF NOT EXISTS message_send_hours_start time DEFAULT '09:00',
ADD COLUMN IF NOT EXISTS message_send_hours_end time DEFAULT '18:00',
ADD COLUMN IF NOT EXISTS message_send_days integer[] DEFAULT ARRAY[1,2,3,4,5];

-- Mevcut şablonlara default değerler ata
UPDATE message_templates
SET 
  message_send_hours_start = '09:00',
  message_send_hours_end = '18:00',
  message_send_days = ARRAY[1,2,3,4,5]
WHERE message_send_hours_start IS NULL;

-- Gecikmiş ödeme için days_before = 2 (ödeme tarihinden 2 gün sonra)
UPDATE message_templates
SET days_before = 2
WHERE category = 'overdue_payment';

-- Kontrol
SELECT 
  template_name,
  category,
  send_time,
  days_before,
  message_send_hours_start,
  message_send_hours_end,
  message_send_days,
  is_active
FROM message_templates
WHERE club_id = (SELECT id FROM clubs WHERE name ILIKE '%atakum%' LIMIT 1)
ORDER BY category;
