-- message_templates tablosuna days_before kolonu ekle

ALTER TABLE message_templates 
ADD COLUMN IF NOT EXISTS days_before integer DEFAULT 3;

COMMENT ON COLUMN message_templates.days_before IS 'Yaklaşan ödemeler için kaç gün önceden uyarı gönderilecek (varsayılan: 3 gün)';
