-- WhatsApp incoming calls tablosuna status kolonu ekle

ALTER TABLE whatsapp_incoming_calls
ADD COLUMN IF NOT EXISTS status VARCHAR(20) DEFAULT 'unanswered';

-- Status değerleri: 'unanswered', 'answered', 'callback', 'other', 'unreachable'

-- Mevcut kayıtları güncelle (varsayılan: unanswered)
UPDATE whatsapp_incoming_calls
SET status = 'unanswered'
WHERE status IS NULL;

-- Index ekle (performans için)
CREATE INDEX IF NOT EXISTS idx_whatsapp_calls_status 
ON whatsapp_incoming_calls(club_id, status, created_at DESC);

-- Kontrol
SELECT club_id, called_number, status, created_at
FROM whatsapp_incoming_calls
ORDER BY created_at DESC
LIMIT 20;
