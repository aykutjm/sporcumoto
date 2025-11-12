-- Settings tablosuna successTitle, successMessage ve branchPayments kolonlarını ekle
-- Bu kolonlar sözleşme şablonu için kullanılıyor

-- 1. successTitle kolonu ekle (kayıt tamamlandı başlığı)
ALTER TABLE settings 
ADD COLUMN IF NOT EXISTS "successTitle" TEXT;

-- 2. successMessage kolonu ekle (kayıt tamamlandı mesajı)
ALTER TABLE settings 
ADD COLUMN IF NOT EXISTS "successMessage" TEXT;

-- 3. branchPayments kolonu ekle (branş bazlı ödeme bilgileri - JSONB)
ALTER TABLE settings 
ADD COLUMN IF NOT EXISTS "branchPayments" JSONB;

-- Varsayılan değerler ekle (opsiyonel)
COMMENT ON COLUMN settings."successTitle" IS 'Kayıt tamamlandığında gösterilecek başlık';
COMMENT ON COLUMN settings."successMessage" IS 'Kayıt tamamlandığında gösterilecek mesaj';
COMMENT ON COLUMN settings."branchPayments" IS 'Branş bazlı ödeme bilgileri (IBAN, hesap sahibi, talimatlar)';

-- Kontrol et
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'settings' 
AND column_name IN ('successTitle', 'successMessage', 'branchPayments')
ORDER BY column_name;

