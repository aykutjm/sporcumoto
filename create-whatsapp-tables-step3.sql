-- ✅ ADIM 3: RLS VE POLİTİKALAR
ALTER TABLE whatsapp_incoming_calls ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their club calls" ON whatsapp_incoming_calls
    FOR SELECT
    USING (auth.uid()::TEXT IN (
        SELECT id::TEXT FROM auth.users WHERE raw_user_meta_data->>'clubId' = club_id
    ));

CREATE POLICY "Users can insert their club calls" ON whatsapp_incoming_calls
    FOR INSERT
    WITH CHECK (auth.uid()::TEXT IN (
        SELECT id::TEXT FROM auth.users WHERE raw_user_meta_data->>'clubId' = club_id
    ));
