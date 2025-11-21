-- ⚠️ MEVCUT TABLO VARSA ÖNCE TEMİZLEME
-- Bu SQL'i Supabase Dashboard > SQL Editor'de çalıştırın

-- 1. Önce mevcut politikaları kaldır
DROP POLICY IF EXISTS "Users can view their club's auto replies" ON autoReplySent;
DROP POLICY IF EXISTS "Service role can insert auto replies" ON autoReplySent;

-- 2. View'ı kaldır (varsa)
DROP VIEW IF EXISTS auto_reply_stats;

-- 3. Tabloyu kaldır (varsa)
DROP TABLE IF EXISTS autoReplySent;

-- 4. Tabloyu yeniden oluştur
CREATE TABLE autoReplySent (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  clubId TEXT NOT NULL,
  phone TEXT NOT NULL,
  formattedPhone TEXT NOT NULL,
  sentDate TIMESTAMP WITH TIME ZONE NOT NULL,
  callTime TEXT,
  deviceUsed TEXT,
  createdAt TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Index ekle (performans için)
CREATE INDEX idx_autoreplysent_club_date ON autoReplySent(clubId, sentDate);
CREATE INDEX idx_autoreplysent_phone ON autoReplySent(phone);

-- 6. RLS (Row Level Security) politikaları
ALTER TABLE autoReplySent ENABLE ROW LEVEL SECURITY;

-- Kulüp sahipleri kendi kayıtlarını görebilir
CREATE POLICY "Users can view their club's auto replies"
  ON autoReplySent
  FOR SELECT
  USING (
    clubId IN (
      SELECT id FROM clubs WHERE id = clubId
    )
  );

-- Edge function tüm kayıtları ekleyebilir (service role)
CREATE POLICY "Service role can insert auto replies"
  ON autoReplySent
  FOR INSERT
  WITH CHECK (true);

-- 7. İstatistik view
CREATE VIEW auto_reply_stats AS
SELECT 
  clubId,
  DATE(sentDate) as date,
  COUNT(*) as total_sent,
  COUNT(DISTINCT phone) as unique_phones,
  deviceUsed
FROM autoReplySent
GROUP BY clubId, DATE(sentDate), deviceUsed
ORDER BY date DESC;

-- 8. Açıklamalar
COMMENT ON TABLE autoReplySent IS 'Cevapsız çağrılara gönderilen otomatik WhatsApp mesajlarını takip eder';
COMMENT ON COLUMN autoReplySent.phone IS 'Orijinal telefon numarası (duplicate kontrolü için)';
COMMENT ON COLUMN autoReplySent.formattedPhone IS 'Formatlanmış telefon numarası (0XXXXXXXXXX)';
COMMENT ON COLUMN autoReplySent.sentDate IS 'Mesajın gönderildiği tarih/saat';
COMMENT ON COLUMN autoReplySent.callTime IS 'Çağrının yapıldığı tarih/saat';
COMMENT ON COLUMN autoReplySent.deviceUsed IS 'Kullanılan WhatsApp cihazı';

-- ✅ TAMAMDIR!
SELECT 'autoReplySent tablosu başarıyla oluşturuldu!' as result;
