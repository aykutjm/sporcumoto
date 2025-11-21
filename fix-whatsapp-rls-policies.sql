-- 🔧 RLS POLİTİKALARINI DÜZELT
-- auth.users tablosuna erişim yerine auth.jwt() kullan

-- 1️⃣ ESKİ POLİTİKALARI SİL
DROP POLICY IF EXISTS "Users can view their club calls" ON whatsapp_incoming_calls;
DROP POLICY IF EXISTS "Users can insert their club calls" ON whatsapp_incoming_calls;
DROP POLICY IF EXISTS "Users can view their club messages" ON whatsapp_incoming_messages;
DROP POLICY IF EXISTS "Users can insert their club messages" ON whatsapp_incoming_messages;

-- 2️⃣ YENİ POLİTİKALAR - auth.jwt() kullanarak
-- ÇAĞRILAR TABLOSU
CREATE POLICY "Users can view their club calls" ON whatsapp_incoming_calls
    FOR SELECT
    USING (
        club_id = (auth.jwt()->>'clubId')
    );

CREATE POLICY "Users can insert their club calls" ON whatsapp_incoming_calls
    FOR INSERT
    WITH CHECK (
        club_id = (auth.jwt()->>'clubId')
    );

-- MESAJLAR TABLOSU
CREATE POLICY "Users can view their club messages" ON whatsapp_incoming_messages
    FOR SELECT
    USING (
        club_id = (auth.jwt()->>'clubId')
    );

CREATE POLICY "Users can insert their club messages" ON whatsapp_incoming_messages
    FOR INSERT
    WITH CHECK (
        club_id = (auth.jwt()->>'clubId')
    );

-- 3️⃣ WEBHOOK İÇİN BYPASS POLİTİKASI (opsiyonel - webhook için service_role kullanacaksanız gerek yok)
-- Eğer webhook public olarak erişecekse, INSERT için ayrı policy gerekebilir
-- Şimdilik yukarıdaki politikalar yeterli, webhook service_role key kullanacak

COMMENT ON POLICY "Users can view their club calls" ON whatsapp_incoming_calls IS 'Kullanıcılar sadece kendi kulüplerinin çağrılarını görebilir';
COMMENT ON POLICY "Users can insert their club calls" ON whatsapp_incoming_calls IS 'Kullanıcılar sadece kendi kulüplerine çağrı ekleyebilir';
COMMENT ON POLICY "Users can view their club messages" ON whatsapp_incoming_messages IS 'Kullanıcılar sadece kendi kulüplerinin mesajlarını görebilir';
COMMENT ON POLICY "Users can insert their club messages" ON whatsapp_incoming_messages IS 'Kullanıcılar sadece kendi kulüplerine mesaj ekleyebilir';
