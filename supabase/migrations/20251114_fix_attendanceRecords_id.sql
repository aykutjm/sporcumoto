-- attendanceRecords tablosundaki id kolonunu UUID'ye çevir ve otomatik generate et
-- Mevcut id'ler TEXT olduğu için önce yedekleyelim

-- 1. Eski TEXT id'leri saklamak için geçici kolon ekle
ALTER TABLE public."attendanceRecords" 
ADD COLUMN IF NOT EXISTS "oldId" TEXT;

-- 2. Mevcut id'leri oldId'ye kopyala
UPDATE public."attendanceRecords" 
SET "oldId" = id 
WHERE "oldId" IS NULL;

-- 3. id kolonunu UUID'ye çevir
-- Önce constraint'leri kaldır
ALTER TABLE public."attendanceRecords" 
DROP CONSTRAINT IF EXISTS "attendanceRecords_pkey";

-- id kolonunu değiştir
ALTER TABLE public."attendanceRecords" 
ALTER COLUMN id TYPE UUID USING gen_random_uuid(),
ALTER COLUMN id SET DEFAULT gen_random_uuid(),
ALTER COLUMN id SET NOT NULL;

-- Primary key'i tekrar ekle
ALTER TABLE public."attendanceRecords" 
ADD PRIMARY KEY (id);

-- 4. createdAt için varsayılan değer ekle (yoksa)
ALTER TABLE public."attendanceRecords" 
ALTER COLUMN "createdAt" SET DEFAULT NOW();

-- 5. Index'leri kontrol et ve ekle
CREATE INDEX IF NOT EXISTS "idx_attendanceRecords_clubId" ON public."attendanceRecords"("clubId");
CREATE INDEX IF NOT EXISTS "idx_attendanceRecords_memberId" ON public."attendanceRecords"("memberId");
CREATE INDEX IF NOT EXISTS "idx_attendanceRecords_date" ON public."attendanceRecords"(date);
CREATE INDEX IF NOT EXISTS "idx_attendanceRecords_groupId" ON public."attendanceRecords"("groupId");

-- Yorum ekle
COMMENT ON COLUMN public."attendanceRecords".id IS 'Yoklama kaydı benzersiz UUID (otomatik oluşturulur)';
COMMENT ON COLUMN public."attendanceRecords"."oldId" IS 'Eski TEXT formatındaki ID (migrasyon için yedek)';
