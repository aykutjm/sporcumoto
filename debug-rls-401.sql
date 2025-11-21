-- 🐛 401 UNAUTHORIZED HATASINI DEBUG ET

-- 1️⃣ JWT içeriğini göster
SELECT 
    auth.jwt() as "Full JWT",
    auth.jwt()->>'clubId' as "JWT clubId",
    auth.jwt()->>'email' as "JWT email",
    auth.jwt()->>'role' as "JWT role",
    auth.jwt()->>'aud' as "JWT audience";

-- 2️⃣ RLS politikalarını listele
SELECT 
    schemaname,
    tablename,
    policyname,
    roles,
    cmd as "Command",
    qual as "USING Expression"
FROM pg_policies 
WHERE tablename IN ('whatsapp_incoming_calls', 'whatsapp_incoming_messages')
ORDER BY tablename, policyname;

-- 3️⃣ RLS aktif mi kontrol et
SELECT 
    tablename,
    rowsecurity as "RLS Enabled"
FROM pg_tables 
WHERE tablename IN ('whatsapp_incoming_calls', 'whatsapp_incoming_messages');

-- 4️⃣ club_id kolonu var mı?
SELECT 
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name IN ('whatsapp_incoming_calls', 'whatsapp_incoming_messages')
    AND column_name = 'club_id';
