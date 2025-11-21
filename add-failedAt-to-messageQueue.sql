-- messageQueue tablosuna failedAt kolonu ekle
ALTER TABLE public."messageQueue" 
ADD COLUMN IF NOT EXISTS "failedAt" TIMESTAMPTZ;

COMMENT ON COLUMN public."messageQueue"."failedAt" IS 'Mesaj gönderilirken hata alınma zamanı';
