-- ✅ ADIM 2: INDEX'LER
CREATE INDEX IF NOT EXISTS idx_whatsapp_messages_club ON whatsapp_incoming_messages (club_id);
CREATE INDEX IF NOT EXISTS idx_whatsapp_messages_timestamp ON whatsapp_incoming_messages (message_timestamp);
CREATE INDEX IF NOT EXISTS idx_whatsapp_messages_remote ON whatsapp_incoming_messages (remote_jid);
CREATE INDEX IF NOT EXISTS idx_whatsapp_messages_timestamp_desc ON whatsapp_incoming_messages (message_timestamp DESC NULLS LAST);
