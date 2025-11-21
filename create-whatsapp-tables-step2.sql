-- ✅ ADIM 2: INDEX'LER
CREATE INDEX IF NOT EXISTS idx_whatsapp_calls_club ON whatsapp_incoming_calls (club_id);
CREATE INDEX IF NOT EXISTS idx_whatsapp_calls_timestamp ON whatsapp_incoming_calls (call_timestamp);
CREATE INDEX IF NOT EXISTS idx_whatsapp_calls_timestamp_desc ON whatsapp_incoming_calls (call_timestamp DESC NULLS LAST);
