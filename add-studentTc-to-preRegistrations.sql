-- ✅ preRegistrations tablosuna studentTc kolonu ekle
-- Öğrenci TC kimlik numarasını saklamak için

-- Kolon ekle (eğer yoksa)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'preRegistrations' 
        AND column_name = 'studentTc'
    ) THEN
        ALTER TABLE "preRegistrations" 
        ADD COLUMN "studentTc" TEXT;
        
        RAISE NOTICE 'studentTc kolonu eklendi';
    ELSE
        RAISE NOTICE 'studentTc kolonu zaten mevcut';
    END IF;
END $$;

-- Kolon açıklaması
COMMENT ON COLUMN "preRegistrations"."studentTc" IS 'Öğrenci TC Kimlik Numarası (11 hane)';

-- Kullanım örneği:
-- UPDATE "preRegistrations" 
-- SET "studentTc" = '12345678901' 
-- WHERE id = 'xxx';
