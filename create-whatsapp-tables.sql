-- ✅ WhatsApp Gelen Çağrılar Tablosu
CREATE TABLE IF NOT EXISTS whatsapp_incoming_calls (
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

-- ✅ Index'ler
CREATE INDEX IF NOT EXISTS idx_whatsapp_calls_club ON whatsapp_incoming_calls (club_id);
CREATE INDEX IF NOT EXISTS idx_whatsapp_calls_timestamp ON whatsapp_incoming_calls (call_timestamp);
-- Sıralama için ayrı index (DESC + NULLS LAST)
CREATE INDEX IF NOT EXISTS idx_whatsapp_calls_timestamp_desc ON whatsapp_incoming_calls (call_timestamp DESC NULLS LAST);

-- ✅ Row Level Security (RLS) - Kulüpler sadece kendi verilerini görebilir
ALTER TABLE whatsapp_incoming_calls ENABLE ROW LEVEL SECURITY;

-- Politika: Kulüpler sadece kendi çağrılarını görebilir
CREATE POLICY "Users can view their club calls" ON whatsapp_incoming_calls
    FOR SELECT
    USING (auth.uid()::TEXT IN (
        SELECT id::TEXT FROM auth.users WHERE raw_user_meta_data->>'clubId' = club_id
    ));

-- Politika: Kulüpler sadece kendi çağrılarını ekleyebilir
CREATE POLICY "Users can insert their club calls" ON whatsapp_incoming_calls
    FOR INSERT
    WITH CHECK (auth.uid()::TEXT IN (
        SELECT id::TEXT FROM auth.users WHERE raw_user_meta_data->>'clubId' = club_id
    ));

COMMENT ON TABLE whatsapp_incoming_calls IS 'WhatsApp gelen çağrı kayıtları';
COMMENT ON COLUMN whatsapp_incoming_calls.caller_phone IS 'Arayan telefon numarası';
COMMENT ON COLUMN whatsapp_incoming_calls.called_number IS 'Aranan numara/instance';
COMMENT ON COLUMN whatsapp_incoming_calls.is_missing_call IS 'Cevapsız çağrı mı?';
