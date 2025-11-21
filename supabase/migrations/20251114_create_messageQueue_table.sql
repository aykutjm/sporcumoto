-- Mesaj kuyruğu tablosu oluştur
CREATE TABLE IF NOT EXISTS public."messageQueue" (
    id TEXT PRIMARY KEY,
    "clubId" TEXT NOT NULL,
    phone TEXT NOT NULL,
    message TEXT NOT NULL,
    "deviceId" TEXT,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'sent', 'failed')),
    "scheduledFor" TIMESTAMPTZ NOT NULL,
    "createdAt" TIMESTAMPTZ DEFAULT NOW(),
    "sentAt" TIMESTAMPTZ,
    error TEXT,
    "retryCount" INTEGER DEFAULT 0
);

-- Index'ler ekle
CREATE INDEX IF NOT EXISTS "idx_messageQueue_clubId" ON public."messageQueue"("clubId");
CREATE INDEX IF NOT EXISTS "idx_messageQueue_status" ON public."messageQueue"(status);
CREATE INDEX IF NOT EXISTS "idx_messageQueue_scheduledFor" ON public."messageQueue"("scheduledFor");
CREATE INDEX IF NOT EXISTS "idx_messageQueue_clubId_status" ON public."messageQueue"("clubId", status);

-- RLS (Row Level Security) politikaları
ALTER TABLE public."messageQueue" ENABLE ROW LEVEL SECURITY;

CREATE POLICY "messageQueue_select_policy" ON public."messageQueue"
    FOR SELECT USING (true);

CREATE POLICY "messageQueue_insert_policy" ON public."messageQueue"
    FOR INSERT WITH CHECK (true);

CREATE POLICY "messageQueue_update_policy" ON public."messageQueue"
    FOR UPDATE USING (true);

CREATE POLICY "messageQueue_delete_policy" ON public."messageQueue"
    FOR DELETE USING (true);

-- Yorum ekle
COMMENT ON TABLE public."messageQueue" IS 'WhatsApp mesaj kuyruğu - çalışma saatleri dışında gönderilecek mesajlar';
COMMENT ON COLUMN public."messageQueue".id IS 'Mesaj benzersiz ID';
COMMENT ON COLUMN public."messageQueue"."clubId" IS 'Kulüp ID';
COMMENT ON COLUMN public."messageQueue".phone IS 'Alıcı telefon numarası';
COMMENT ON COLUMN public."messageQueue".message IS 'Gönderilecek mesaj metni';
COMMENT ON COLUMN public."messageQueue"."deviceId" IS 'WhatsApp cihaz ID (instanceName)';
COMMENT ON COLUMN public."messageQueue".status IS 'Mesaj durumu: pending, sent, failed';
COMMENT ON COLUMN public."messageQueue"."scheduledFor" IS 'Mesajın gönderileceği tarih/saat';
COMMENT ON COLUMN public."messageQueue"."createdAt" IS 'Kuyruğa eklenme zamanı';
COMMENT ON COLUMN public."messageQueue"."sentAt" IS 'Gönderilme zamanı';
COMMENT ON COLUMN public."messageQueue".error IS 'Hata mesajı (başarısız olursa)';
COMMENT ON COLUMN public."messageQueue"."retryCount" IS 'Tekrar deneme sayısı';
