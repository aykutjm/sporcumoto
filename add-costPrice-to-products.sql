-- Products tablosuna costPrice kolonu ekle (eğer yoksa)
ALTER TABLE public.products 
ADD COLUMN IF NOT EXISTS "costPrice" NUMERIC(10, 2) DEFAULT 0;

-- Mevcut kayıtlar için default değer ata
UPDATE public.products 
SET "costPrice" = 0 
WHERE "costPrice" IS NULL;
