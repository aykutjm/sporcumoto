-- ✅ ADIM 1: TABLO OLUŞTUR
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
