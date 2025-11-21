-- 🔧 WhatsApp Devices RLS POLİTİKALARINI DÜZELT
-- Problem: 403 Hatası - Cihaz eklenemiyor
-- Çözüm: RLS politikalarını ekle veya RLS'i devre dışı bırak

-- SEÇENEK 1: RLS'İ KAPALI BIRAK (Önerilen - Firebase uyumluluğu için)
-- Eğer Firebase'den geldiyseniz, RLS kapalı daha uyumlu olur
ALTER TABLE "whatsappDevices" DISABLE ROW LEVEL SECURITY;

-- GRANT komutuyla yetkileri kontrol et
GRANT ALL ON "whatsappDevices" TO authenticated;
GRANT ALL ON "whatsappDevices" TO anon;
GRANT ALL ON "whatsappDevices" TO service_role;

-- ✅ Kontrol: Mevcut RLS durumunu göster
SELECT 
    schemaname,
    tablename,
    rowsecurity as "RLS Enabled"
FROM pg_tables 
WHERE tablename = 'whatsappDevices';

-- ✅ Kontrol: Mevcut policy'leri göster (varsa)
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'whatsappDevices';

-- ══════════════════════════════════════════════════════════════
-- SEÇENEK 2: RLS'İ AÇIK TUTMAK İSTERSENİZ (Alternatif)
-- Sadece aşağıdaki satırları çalıştırın (yukarıdakileri ÇALIŞTIRMAYIN)
-- ══════════════════════════════════════════════════════════════

/*
-- Önce eski policy'leri temizle
DROP POLICY IF EXISTS "Users can view their club devices" ON "whatsappDevices";
DROP POLICY IF EXISTS "Users can insert their club devices" ON "whatsappDevices";
DROP POLICY IF EXISTS "Users can update their club devices" ON "whatsappDevices";
DROP POLICY IF EXISTS "Users can delete their club devices" ON "whatsappDevices";

-- RLS'i aktif et
ALTER TABLE "whatsappDevices" ENABLE ROW LEVEL SECURITY;

-- Kullanıcılar kendi kulüplerinin cihazlarını görebilir
CREATE POLICY "Users can view their club devices"
ON "whatsappDevices"
FOR SELECT
TO authenticated
USING ("clubId" = (auth.jwt()->>'clubId'));

-- Kullanıcılar kendi kulüplerine cihaz ekleyebilir
CREATE POLICY "Users can insert their club devices"
ON "whatsappDevices"
FOR INSERT
TO authenticated
WITH CHECK ("clubId" = (auth.jwt()->>'clubId'));

-- Kullanıcılar kendi kulüplerinin cihazlarını güncelleyebilir
CREATE POLICY "Users can update their club devices"
ON "whatsappDevices"
FOR UPDATE
TO authenticated
USING ("clubId" = (auth.jwt()->>'clubId'))
WITH CHECK ("clubId" = (auth.jwt()->>'clubId'));

-- Kullanıcılar kendi kulüplerinin cihazlarını silebilir
CREATE POLICY "Users can delete their club devices"
ON "whatsappDevices"
FOR DELETE
TO authenticated
USING ("clubId" = (auth.jwt()->>'clubId'));

-- Kontrol: Yeni policy'leri göster
SELECT policyname, cmd, qual, with_check 
FROM pg_policies 
WHERE tablename = 'whatsappDevices';
*/

-- ✅ BAŞARILI MESAJI
DO $$
BEGIN
    RAISE NOTICE '══════════════════════════════════════════════════';
    RAISE NOTICE '✅ WhatsApp Devices RLS düzenlemesi tamamlandı!';
    RAISE NOTICE '';
    RAISE NOTICE '🔧 Yapılan işlemler:';
    RAISE NOTICE '   - RLS DISABLED (Kapalı)';
    RAISE NOTICE '   - GRANT yetkiler verildi';
    RAISE NOTICE '';
    RAISE NOTICE '📝 Not: Eğer RLS açık kullanmak isterseniz,';
    RAISE NOTICE '   dosyadaki SEÇENEK 2 kısmını çalıştırın';
    RAISE NOTICE '══════════════════════════════════════════════════';
END $$;
