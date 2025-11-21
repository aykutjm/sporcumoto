-- autoMessageSettings tablosuna triggerTime (saat) ekle
ALTER TABLE "autoMessageSettings"
ADD COLUMN IF NOT EXISTS "triggerTime" TEXT DEFAULT '10:00';

COMMENT ON COLUMN "autoMessageSettings"."triggerTime" IS 'Mesaj gönderim saati (HH:MM formatında)';
