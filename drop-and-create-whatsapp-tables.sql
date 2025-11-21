-- 🗑️ ESKİ TABLOLARI SİL (varsa)
DROP TABLE IF EXISTS whatsapp_incoming_calls CASCADE;
DROP TABLE IF EXISTS whatsapp_incoming_messages CASCADE;

-- ✅ ÇAĞRILAR TABLOSU OLUŞTUR
CREATE TABLE whatsapp_incoming_calls (
    id BIGSERIAL PRIMARY KEY,
    club_id TEXT NOT NULL,
    caller_phone TEXT,
    caller_name TEXT,
    called_number TEXT,
    instance_name TEXT,
    call_timestamp TIMESTAMPTZ DEFAULT NOW(),
    call_status TEXT,
    is_video BOOLEAN DEFAULT FALSE,
    call_id TEXT,
    is_missing_call BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index'ler
CREATE INDEX idx_whatsapp_calls_club ON whatsapp_incoming_calls (club_id);
CREATE INDEX idx_whatsapp_calls_timestamp ON whatsapp_incoming_calls (call_timestamp);
CREATE INDEX idx_whatsapp_calls_timestamp_desc ON whatsapp_incoming_calls (call_timestamp DESC NULLS LAST);

-- RLS
ALTER TABLE whatsapp_incoming_calls ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their club calls" ON whatsapp_incoming_calls
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.id = auth.uid() 
            AND auth.users.raw_user_meta_data->>'clubId' = whatsapp_incoming_calls.club_id
        )
    );

CREATE POLICY "Users can insert their club calls" ON whatsapp_incoming_calls
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.id = auth.uid() 
            AND auth.users.raw_user_meta_data->>'clubId' = whatsapp_incoming_calls.club_id
        )
    );

-- ✅ MESAJLAR TABLOSU OLUŞTUR
CREATE TABLE whatsapp_incoming_messages (
    id BIGSERIAL PRIMARY KEY,
    club_id TEXT NOT NULL,
    remote_jid TEXT,
    push_name TEXT,
    instance_name TEXT,
    message_timestamp TIMESTAMPTZ DEFAULT NOW(),
    message_timestamp_unix BIGINT,
    message_content JSONB,
    message_key JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index'ler
CREATE INDEX idx_whatsapp_messages_club ON whatsapp_incoming_messages (club_id);
CREATE INDEX idx_whatsapp_messages_timestamp ON whatsapp_incoming_messages (message_timestamp);
CREATE INDEX idx_whatsapp_messages_remote ON whatsapp_incoming_messages (remote_jid);
CREATE INDEX idx_whatsapp_messages_timestamp_desc ON whatsapp_incoming_messages (message_timestamp DESC NULLS LAST);

-- RLS
ALTER TABLE whatsapp_incoming_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their club messages" ON whatsapp_incoming_messages
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.id = auth.uid() 
            AND auth.users.raw_user_meta_data->>'clubId' = whatsapp_incoming_messages.club_id
        )
    );

CREATE POLICY "Users can insert their club messages" ON whatsapp_incoming_messages
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM auth.users 
            WHERE auth.users.id = auth.uid() 
            AND auth.users.raw_user_meta_data->>'clubId' = whatsapp_incoming_messages.club_id
        )
    );

-- Yorumlar
COMMENT ON TABLE whatsapp_incoming_calls IS 'WhatsApp gelen çağrı kayıtları';
COMMENT ON TABLE whatsapp_incoming_messages IS 'WhatsApp gelen mesaj kayıtları';
