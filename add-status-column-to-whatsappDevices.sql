-- ✅ whatsappDevices tablosuna eksik kolonları ekleme
-- Mevcut kolonlar kontrol edildi, sadece isConnected eksik

-- 1️⃣ isConnected kolonu ekle (tek eksik kolon bu)
ALTER TABLE "whatsappDevices" 
ADD COLUMN IF NOT EXISTS "isConnected" BOOLEAN DEFAULT false;

-- 2️⃣ Mevcut verileri senkronize et
UPDATE "whatsappDevices"
SET "isConnected" = CASE 
    WHEN "status" = 'connected' THEN true
    ELSE false
END
WHERE "isConnected" IS NULL;

-- ✅ BAŞARILI MESAJI
DO $$
BEGIN
    RAISE NOTICE '✅ whatsappDevices tablosuna isConnected kolonu eklendi!';
    RAISE NOTICE '   - isConnected: BOOLEAN (bağlantı durumu)';
    RAISE NOTICE '';
    RAISE NOTICE '📋 Mevcut tablo yapısı:';
    RAISE NOTICE '   ✓ id, clubId, instanceName, phoneNumber';
    RAISE NOTICE '   ✓ apiKey, evolutionUrl';
    RAISE NOTICE '   ✓ status, lastUpdated, isConnected';
    RAISE NOTICE '   ✓ createdAt, createdBy, updatedAt';
END $$;
