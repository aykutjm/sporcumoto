-- messageQueue tablosuna eksik kolonları ekle

-- createdBy kolonu ekle
ALTER TABLE "messageQueue"
ADD COLUMN IF NOT EXISTS "createdBy" TEXT;

-- type kolonu ekle
ALTER TABLE "messageQueue"
ADD COLUMN IF NOT EXISTS "type" TEXT;

-- Mevcut kayıtları güncelle
UPDATE "messageQueue"
SET "createdBy" = 'Sistem'
WHERE "createdBy" IS NULL;

UPDATE "messageQueue"
SET "type" = 'manual'
WHERE "type" IS NULL;

-- Kontrol
SELECT "clubId", "phone", "status", "createdBy", "createdAt", "type"
FROM "messageQueue"
ORDER BY "createdAt" DESC
LIMIT 10;
