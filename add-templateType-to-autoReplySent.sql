-- autoReplySent tablosuna templateType kolonu ekle
-- Aynı gün aynı kişiye aynı şablon gönderilmemesi için

-- Önce tablo var mı kontrol et, yoksa oluştur
CREATE TABLE IF NOT EXISTS autoReplySent (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  clubId TEXT NOT NULL,
  phone TEXT NOT NULL,
  formattedPhone TEXT NOT NULL,
  sentDate TIMESTAMP WITH TIME ZONE NOT NULL,
  callTime TEXT,
  deviceUsed TEXT,
  createdAt TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- templateType kolonunu ekle
ALTER TABLE autoReplySent
ADD COLUMN IF NOT EXISTS templateType VARCHAR(100) DEFAULT 'cevapsiz_arama';

-- Index ekle (phone + templateType + sentDate kombinasyonu için)
CREATE INDEX IF NOT EXISTS idx_autoreplysent_phone_template_date 
ON autoReplySent(phone, templateType, sentDate);

-- RLS aktif et
ALTER TABLE autoReplySent ENABLE ROW LEVEL SECURITY;

-- RLS Politikaları (mevcut politikaları kaldır)
DROP POLICY IF EXISTS "Service role can insert auto replies" ON autoReplySent;
DROP POLICY IF EXISTS "Service can insert auto replies" ON autoReplySent;

-- Yeni politika: anon key de INSERT yapabilsin
CREATE POLICY "Service can insert auto replies"
ON autoReplySent
FOR INSERT
TO authenticated, anon
WITH CHECK (true);

-- Kontrol
SELECT 
    column_name,
    data_type,
    character_maximum_length
FROM information_schema.columns 
WHERE table_name = 'autoreplysent'
ORDER BY ordinal_position;
