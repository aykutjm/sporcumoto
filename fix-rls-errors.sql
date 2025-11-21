-- RLS (Row Level Security) Hatalarını Düzelt
-- Policy'ler var ama RLS enabled değil olan tablolar için

-- 1. messageQueue tablosu için RLS'yi etkinleştir
ALTER TABLE "messageQueue" ENABLE ROW LEVEL SECURITY;

-- 2. Diğer WhatsApp tabloları için de kontrol (muhtemelen aynı hata onlarda da var)
ALTER TABLE "whatsappDevices" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "whatsappIncomingCalls" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "whatsappIncomingMessages" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "whatsappMessages" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "sentMessages" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "scheduledMessages" ENABLE ROW LEVEL SECURITY;

-- 3. autoReplySent tablosu için de (yeni oluşturacağımız)
-- Bu tablo henüz yoksa hata verecek, o yüzden yorumda bırakıyorum
-- ALTER TABLE "autoReplySent" ENABLE ROW LEVEL SECURITY;

-- Kontrol sorgusu
SELECT 
    schemaname,
    tablename,
    rowsecurity as "RLS Enabled"
FROM pg_tables
WHERE schemaname = 'public'
    AND tablename IN ('messageQueue', 'whatsappDevices', 'whatsappIncomingCalls', 
                      'whatsappIncomingMessages', 'whatsappMessages', 'sentMessages', 'scheduledMessages')
ORDER BY tablename;
