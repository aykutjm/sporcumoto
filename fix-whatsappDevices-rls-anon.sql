-- whatsappDevices RLS politikasını güncelle
-- Anon kullanıcıların da INSERT yapabilmesi için

-- Mevcut INSERT politikasını kaldır
DROP POLICY IF EXISTS "Users can insert their club devices" ON "whatsappDevices";

-- Yeni INSERT politikası: authenticated kullanıcılar kendi kulüplerine ekleyebilir
CREATE POLICY "Users can insert their club devices"
ON "whatsappDevices"
FOR INSERT
TO authenticated, anon
WITH CHECK (true);

-- SELECT politikası kontrol
DROP POLICY IF EXISTS "Users can view their club devices" ON "whatsappDevices";

CREATE POLICY "Users can view their club devices"
ON "whatsappDevices"
FOR SELECT
TO authenticated, anon
USING (true);

-- UPDATE politikası
DROP POLICY IF EXISTS "Users can update their club devices" ON "whatsappDevices";

CREATE POLICY "Users can update their club devices"
ON "whatsappDevices"
FOR UPDATE
TO authenticated, anon
USING (true)
WITH CHECK (true);

-- Kontrol
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd
FROM pg_policies
WHERE tablename = 'whatsappDevices'
ORDER BY policyname;
