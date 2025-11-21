-- messageTemplates tablosuna isActive kolonu ekle
ALTER TABLE "messageTemplates" 
ADD COLUMN IF NOT EXISTS "isActive" BOOLEAN DEFAULT true;

-- Mevcut tüm şablonları aktif yap
UPDATE "messageTemplates" SET "isActive" = true WHERE "isActive" IS NULL;

-- Yorum ekle
COMMENT ON COLUMN "messageTemplates"."isActive" IS 'Mesaj şablonunun otomatik gönderim için aktif olup olmadığı';

-- RLS policy güncelle (SELECT izinlerine isActive kontrolü ekle)
-- Mevcut policy'leri kontrol et
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies 
WHERE tablename = 'messageTemplates';
