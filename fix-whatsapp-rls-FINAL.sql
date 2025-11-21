-- 🔥 WHATSAPP RLS POLİTİKALARINI TAM OLARAK DÜZELT
-- Problem: Eski policy'ler auth.users kullanıyor, ama JWT'de clubId var
-- Çözüm: Tamamen sil ve auth.jwt()->>'clubId' ile yeniden oluştur

-- 1️⃣ ÖNCE HER ŞEYİ SİL
DROP POLICY IF EXISTS "Users can view their club calls" ON whatsapp_incoming_calls;
DROP POLICY IF EXISTS "Users can insert their club calls" ON whatsapp_incoming_calls;
DROP POLICY IF EXISTS "Users can update their club calls" ON whatsapp_incoming_calls;
DROP POLICY IF EXISTS "Users can delete their club calls" ON whatsapp_incoming_calls;
DROP POLICY IF EXISTS "Users can view their club messages" ON whatsapp_incoming_messages;
DROP POLICY IF EXISTS "Users can insert their club messages" ON whatsapp_incoming_messages;
DROP POLICY IF EXISTS "Users can update their club messages" ON whatsapp_incoming_messages;
DROP POLICY IF EXISTS "Users can delete their club messages" ON whatsapp_incoming_messages;

-- 2️⃣ RLS'İ ETKİNLEŞTİR (tekrar aktif etmek için)
ALTER TABLE whatsapp_incoming_calls ENABLE ROW LEVEL SECURITY;
ALTER TABLE whatsapp_incoming_messages ENABLE ROW LEVEL SECURITY;

-- 3️⃣ YENİ POLİTİKALAR - auth.jwt()->>'clubId' ile
-- ÇAĞRILAR TABLOSU
CREATE POLICY "Users can view their club calls"
ON whatsapp_incoming_calls
FOR SELECT
TO authenticated
USING (club_id = (auth.jwt()->>'clubId'));

CREATE POLICY "Users can insert their club calls"
ON whatsapp_incoming_calls
FOR INSERT
TO authenticated
WITH CHECK (club_id = (auth.jwt()->>'clubId'));

CREATE POLICY "Users can update their club calls"
ON whatsapp_incoming_calls
FOR UPDATE
TO authenticated
USING (club_id = (auth.jwt()->>'clubId'))
WITH CHECK (club_id = (auth.jwt()->>'clubId'));

CREATE POLICY "Users can delete their club calls"
ON whatsapp_incoming_calls
FOR DELETE
TO authenticated
USING (club_id = (auth.jwt()->>'clubId'));

-- MESAJLAR TABLOSU
CREATE POLICY "Users can view their club messages"
ON whatsapp_incoming_messages
FOR SELECT
TO authenticated
USING (club_id = (auth.jwt()->>'clubId'));

CREATE POLICY "Users can insert their club messages"
ON whatsapp_incoming_messages
FOR INSERT
TO authenticated
WITH CHECK (club_id = (auth.jwt()->>'clubId'));

CREATE POLICY "Users can update their club messages"
ON whatsapp_incoming_messages
FOR UPDATE
TO authenticated
USING (club_id = (auth.jwt()->>'clubId'))
WITH CHECK (club_id = (auth.jwt()->>'clubId'));

CREATE POLICY "Users can delete their club messages"
ON whatsapp_incoming_messages
FOR DELETE
TO authenticated
USING (club_id = (auth.jwt()->>'clubId'));

-- 4️⃣ KONTROL - Policy'leri listele
SELECT 
    tablename,
    policyname,
    cmd,
    qual as "USING Expression"
FROM pg_policies 
WHERE tablename IN ('whatsapp_incoming_calls', 'whatsapp_incoming_messages')
ORDER BY tablename, policyname;
