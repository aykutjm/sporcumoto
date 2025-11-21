-- 🔍 WhatsApp Devices 403 Hatasını Debug Et
-- Bu sorguları sırayla çalıştırarak sorunu tespit edin

-- 1️⃣ Tablo var mı kontrol et
SELECT EXISTS (
    SELECT FROM pg_tables
    WHERE schemaname = 'public'
    AND tablename = 'whatsappDevices'
) as table_exists;

-- 2️⃣ RLS aktif mi?
SELECT 
    schemaname,
    tablename,
    rowsecurity as "RLS_ENABLED",
    CASE 
        WHEN rowsecurity THEN '⚠️ RLS AÇIK - Policy gerekli'
        ELSE '✅ RLS KAPALI - Direkt erişim'
    END as status
FROM pg_tables 
WHERE tablename = 'whatsappDevices';

-- 3️⃣ Mevcut policy'leri listele
SELECT 
    policyname as "Policy Adı",
    cmd as "Komut",
    roles as "Roller",
    CASE 
        WHEN cmd = 'SELECT' THEN 'Görüntüleme'
        WHEN cmd = 'INSERT' THEN 'Ekleme'
        WHEN cmd = 'UPDATE' THEN 'Güncelleme'
        WHEN cmd = 'DELETE' THEN 'Silme'
        ELSE 'Tümü'
    END as "İşlem",
    qual as "USING Koşulu",
    with_check as "WITH CHECK Koşulu"
FROM pg_policies 
WHERE tablename = 'whatsappDevices';

-- 4️⃣ Tablo yapısını kontrol et
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'whatsappDevices'
ORDER BY ordinal_position;

-- 5️⃣ Yetkiler (GRANT) kontrol et
SELECT 
    grantee,
    privilege_type
FROM information_schema.table_privileges
WHERE table_name = 'whatsappDevices'
ORDER BY grantee, privilege_type;

-- 6️⃣ Mevcut kayıtları say
SELECT COUNT(*) as total_devices FROM "whatsappDevices";

-- 7️⃣ clubId ile kayıtları göster (varsa)
SELECT 
    id,
    "clubId",
    "instanceName",
    "phoneNumber",
    status,
    "isConnected",
    "createdAt"
FROM "whatsappDevices"
LIMIT 5;

-- ══════════════════════════════════════════════════════════════
-- 📊 SONUÇ DEĞERLENDİRMESİ:
-- ══════════════════════════════════════════════════════════════
-- 
-- Eğer RLS_ENABLED = true ise:
--   ✅ Policy'ler olmalı (3. sorgu sonuçları)
--   ❌ Policy yoksa veya yanlışsa -> 403 hatası normal
--   👉 Çözüm: fix-whatsappDevices-rls.sql dosyasını çalıştır
--
-- Eğer RLS_ENABLED = false ise:
--   ✅ Policy gerekmez
--   ❌ GRANT yetkiler eksikse -> 403 hatası olabilir
--   👉 Çözüm: fix-whatsappDevices-rls.sql dosyasını çalıştır
--
-- ══════════════════════════════════════════════════════════════

-- ✅ Özet rapor
DO $$
DECLARE
    rls_status boolean;
    policy_count integer;
    grant_count integer;
BEGIN
    -- RLS durumu
    SELECT rowsecurity INTO rls_status
    FROM pg_tables 
    WHERE tablename = 'whatsappDevices';
    
    -- Policy sayısı
    SELECT COUNT(*) INTO policy_count
    FROM pg_policies 
    WHERE tablename = 'whatsappDevices';
    
    -- Grant sayısı
    SELECT COUNT(*) INTO grant_count
    FROM information_schema.table_privileges
    WHERE table_name = 'whatsappDevices';
    
    RAISE NOTICE '══════════════════════════════════════════════════';
    RAISE NOTICE '📊 WHATSAPP DEVICES DURUM RAPORU';
    RAISE NOTICE '══════════════════════════════════════════════════';
    RAISE NOTICE '';
    RAISE NOTICE 'RLS Durumu: %', CASE WHEN rls_status THEN '🔒 AÇIK' ELSE '✅ KAPALI' END;
    RAISE NOTICE 'Policy Sayısı: %', policy_count;
    RAISE NOTICE 'Grant Sayısı: %', grant_count;
    RAISE NOTICE '';
    
    IF rls_status AND policy_count = 0 THEN
        RAISE NOTICE '⚠️ SORUN TESPİT EDİLDİ!';
        RAISE NOTICE '   RLS açık ama policy yok!';
        RAISE NOTICE '   👉 fix-whatsappDevices-rls.sql dosyasını çalıştırın';
    ELSIF NOT rls_status AND grant_count < 3 THEN
        RAISE NOTICE '⚠️ SORUN TESPİT EDİLDİ!';
        RAISE NOTICE '   RLS kapalı ama GRANT yetkiler eksik!';
        RAISE NOTICE '   👉 fix-whatsappDevices-rls.sql dosyasını çalıştırın';
    ELSE
        RAISE NOTICE '✅ Yapılandırma normal görünüyor';
        RAISE NOTICE '   403 hatası başka sebepten kaynaklanıyor olabilir';
        RAISE NOTICE '   - API Key kontrolü: %', 'iHAF8gWNA1axdRDY9e98UKpork00dBO2';
        RAISE NOTICE '   - Evolution API URL: https://evo-2.edu-ai.online';
    END IF;
    
    RAISE NOTICE '══════════════════════════════════════════════════';
END $$;
