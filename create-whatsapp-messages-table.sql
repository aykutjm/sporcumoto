-- ✅ WhatsApp Gelen Mesajlar Tablosu
CREATE TABLE IF NOT EXISTS whatsapp_incoming_messages (
    id BIGSERIAL PRIMARY KEY,
    club_id TEXT NOT NULL,
    remote_jid TEXT,        -- Mesajı gönderen (@s.whatsapp.net)
    push_name TEXT,         -- Gönderen adı
    instance_name TEXT,
    message_timestamp TIMESTAMPTZ DEFAULT NOW(),
    message_timestamp_unix BIGINT,
    message_content JSONB,  -- Mesaj içeriği (conversation, extendedTextMessage, imageMessage, vb.)
    message_key JSONB,      -- Mesaj key bilgileri (id, fromMe, remoteJid)
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ✅ Index'ler
CREATE INDEX IF NOT EXISTS idx_whatsapp_messages_club ON whatsapp_incoming_messages (club_id);
CREATE INDEX IF NOT EXISTS idx_whatsapp_messages_timestamp ON whatsapp_incoming_messages (message_timestamp);
CREATE INDEX IF NOT EXISTS idx_whatsapp_messages_remote ON whatsapp_incoming_messages (remote_jid);
-- Sıralama için ayrı index (DESC + NULLS LAST)
CREATE INDEX IF NOT EXISTS idx_whatsapp_messages_timestamp_desc ON whatsapp_incoming_messages (message_timestamp DESC NULLS LAST);

-- ✅ Row Level Security (RLS)
ALTER TABLE whatsapp_incoming_messages ENABLE ROW LEVEL SECURITY;

-- Politika: Kulüpler sadece kendi mesajlarını görebilir
CREATE POLICY "Users can view their club messages" ON whatsapp_incoming_messages
    FOR SELECT
    USING (auth.uid()::TEXT IN (
        SELECT id::TEXT FROM auth.users WHERE raw_user_meta_data->>'clubId' = club_id
    ));

-- Politika: Kulüpler sadece kendi mesajlarını ekleyebilir
CREATE POLICY "Users can insert their club messages" ON whatsapp_incoming_messages
    FOR INSERT
    WITH CHECK (auth.uid()::TEXT IN (
        SELECT id::TEXT FROM auth.users WHERE raw_user_meta_data->>'clubId' = club_id
    ));

COMMENT ON TABLE whatsapp_incoming_messages IS 'WhatsApp gelen mesaj kayıtları (webhook)';
COMMENT ON COLUMN whatsapp_incoming_messages.remote_jid IS 'Mesajı gönderen telefon numarası (@s.whatsapp.net)';
COMMENT ON COLUMN whatsapp_incoming_messages.message_content IS 'Mesaj içeriği (JSONB)';
COMMENT ON COLUMN whatsapp_incoming_messages.message_key IS 'Mesaj key bilgileri (id, fromMe, remoteJid)';
