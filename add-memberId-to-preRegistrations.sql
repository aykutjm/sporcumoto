-- ✅ preRegistrations tablosuna memberId kolonu ekle
-- Members tablosu ile ilişki kurmak için

-- Kolon ekle (eğer yoksa)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'preRegistrations' 
        AND column_name = 'memberId'
    ) THEN
        ALTER TABLE "preRegistrations" 
        ADD COLUMN "memberId" TEXT;
        
        RAISE NOTICE 'memberId kolonu eklendi';
    ELSE
        RAISE NOTICE 'memberId kolonu zaten mevcut';
    END IF;
END $$;

-- Kolon açıklaması
COMMENT ON COLUMN "preRegistrations"."memberId" IS 'İlişkili member kaydının ID''si';

-- Index ekle (sorgu performansı için)
CREATE INDEX IF NOT EXISTS idx_preRegistrations_memberId 
ON "preRegistrations"("memberId");

-- Test için bu kaydı güncelle
UPDATE "preRegistrations"
SET "memberId" = 'members_1764072346420_4dle3h3gc'
WHERE "clubId" = 'FmvoFvTCek44CR3pS4XC'
  AND "studentTc" = '26690295076'
  AND "memberId" IS NULL;
