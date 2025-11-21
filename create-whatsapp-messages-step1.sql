-- ✅ ADIM 1: TABLO OLUŞTUR
CREATE TABLE IF NOT EXISTS whatsapp_incoming_messages (
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
