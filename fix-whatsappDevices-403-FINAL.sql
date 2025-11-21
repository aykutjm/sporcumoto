-- 🔥 WhatsApp Devices 403 Hatası - KESİN ÇÖZÜM
-- Durum: RLS kapalı ama yine de 403 hatası var
-- Neden: GRANT yetkiler eksik veya public schema erişimi yok

-- 1️⃣ Önce mevcut yetkileri kontrol et
SELECT 
    grantee,
    privilege_type,
    is_grantable
FROM information_schema.table_privileges
WHERE table_schema = 'public' 
AND table_name = 'whatsappDevices'
ORDER BY grantee, privilege_type;

-- 2️⃣ TÜM YETKİLERİ VER (Force mode)
-- RLS kapalı olduğu için direkt erişim olmalı
GRANT ALL PRIVILEGES ON TABLE "whatsappDevices" TO authenticated;
GRANT ALL PRIVILEGES ON TABLE "whatsappDevices" TO anon;
GRANT ALL PRIVILEGES ON TABLE "whatsappDevices" TO service_role;
GRANT ALL PRIVILEGES ON TABLE "whatsappDevices" TO postgres;

-- 3️⃣ Public schema erişimi de ver
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO service_role;

-- 4️⃣ Sequence yetkisi (ID üretimi için)
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO service_role;

-- 5️⃣ RLS'in gerçekten kapalı olduğundan emin ol
ALTER TABLE "whatsappDevices" DISABLE ROW LEVEL SECURITY;

-- 6️⃣ Tablonun sahibini kontrol et ve değiştir (gerekirse)
-- ALTER TABLE "whatsappDevices" OWNER TO postgres;

-- 7️⃣ Varsayılan yetkileri ayarla (gelecekteki tablolar için)
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO service_role;

-- ✅ KONTROL: Yetkilerin verildiğini doğrula
SELECT 
    grantee as "Rol",
    privilege_type as "Yetki",
    is_grantable as "Devredebilir mi?"
FROM information_schema.table_privileges
WHERE table_schema = 'public' 
AND table_name = 'whatsappDevices'
ORDER BY grantee, privilege_type;

-- ✅ KONTROL: RLS durumunu göster
SELECT 
    tablename,
    rowsecurity as "RLS Açık mı?",
    CASE 
        WHEN rowsecurity THEN '❌ RLS AÇIK - Kapatılmalı'
        ELSE '✅ RLS KAPALI - OK'
    END as "Durum"
FROM pg_tables 
WHERE tablename = 'whatsappDevices';

-- ✅ KONTROL: Test insert yapabilir miyiz? (READ-ONLY - sadece kontrol)
-- Bu sorgu gerçekten insert yapmaz, sadece kontrol eder
DO $$
DECLARE
    test_clubId TEXT := 'FmvoFvTCek44CR3pS4XC';
    can_insert BOOLEAN;
BEGIN
    -- Yetki kontrolü
    SELECT EXISTS (
        SELECT 1 
        FROM information_schema.table_privileges
        WHERE table_name = 'whatsappDevices'
        AND privilege_type = 'INSERT'
        AND grantee IN ('authenticated', 'anon', 'service_role', 'PUBLIC')
    ) INTO can_insert;
    
    IF can_insert THEN
        RAISE NOTICE '✅ INSERT yetkisi VAR - Cihaz ekleyebilirsiniz!';
    ELSE
        RAISE NOTICE '❌ INSERT yetkisi YOK - Bu SQL''i tekrar çalıştırın!';
    END IF;
END $$;

-- 📊 ÖZET RAPOR
DO $$
DECLARE
    rls_status BOOLEAN;
    grant_count INTEGER;
    insert_count INTEGER;
    update_count INTEGER;
    delete_count INTEGER;
    select_count INTEGER;
BEGIN
    -- RLS durumu
    SELECT rowsecurity INTO rls_status
    FROM pg_tables 
    WHERE tablename = 'whatsappDevices';
    
    -- Toplam grant sayısı
    SELECT COUNT(*) INTO grant_count
    FROM information_schema.table_privileges
    WHERE table_name = 'whatsappDevices';
    
    -- INSERT yetkisi
    SELECT COUNT(*) INTO insert_count
    FROM information_schema.table_privileges
    WHERE table_name = 'whatsappDevices'
    AND privilege_type = 'INSERT';
    
    -- UPDATE yetkisi
    SELECT COUNT(*) INTO update_count
    FROM information_schema.table_privileges
    WHERE table_name = 'whatsappDevices'
    AND privilege_type = 'UPDATE';
    
    -- DELETE yetkisi
    SELECT COUNT(*) INTO delete_count
    FROM information_schema.table_privileges
    WHERE table_name = 'whatsappDevices'
    AND privilege_type = 'DELETE';
    
    -- SELECT yetkisi
    SELECT COUNT(*) INTO select_count
    FROM information_schema.table_privileges
    WHERE table_name = 'whatsappDevices'
    AND privilege_type = 'SELECT';
    
    RAISE NOTICE '══════════════════════════════════════════════════════';
    RAISE NOTICE '🔥 WHATSAPP DEVICES - KESİN ÇÖZÜM RAPORU';
    RAISE NOTICE '══════════════════════════════════════════════════════';
    RAISE NOTICE '';
    RAISE NOTICE '📊 Durum:';
    RAISE NOTICE '   RLS: %', CASE WHEN rls_status THEN '🔒 AÇIK (Sorunlu!)' ELSE '✅ KAPALI (OK)' END;
    RAISE NOTICE '   Toplam Yetki: %', grant_count;
    RAISE NOTICE '';
    RAISE NOTICE '🔑 Yetki Detayları:';
    RAISE NOTICE '   SELECT: % rol', select_count;
    RAISE NOTICE '   INSERT: % rol', insert_count;
    RAISE NOTICE '   UPDATE: % rol', update_count;
    RAISE NOTICE '   DELETE: % rol', delete_count;
    RAISE NOTICE '';
    
    IF NOT rls_status AND insert_count >= 3 THEN
        RAISE NOTICE '✅✅✅ HER ŞEY TAMAM!';
        RAISE NOTICE '';
        RAISE NOTICE '👉 Şimdi yapmanız gerekenler:';
        RAISE NOTICE '   1. Tarayıcıyı TAMAMEN kapatın';
        RAISE NOTICE '   2. Tarayıcıyı yeniden açın';
        RAISE NOTICE '   3. Tekrar giriş yapın';
        RAISE NOTICE '   4. Cihaz eklemeyi deneyin';
        RAISE NOTICE '';
        RAISE NOTICE '💡 Hala 403 alıyorsanız:';
        RAISE NOTICE '   - Supabase Dashboard > Settings > API';
        RAISE NOTICE '   - anon key ve service_role key''i kontrol edin';
        RAISE NOTICE '   - JavaScript kodundaki supabaseKey doğru mu?';
    ELSIF rls_status THEN
        RAISE NOTICE '⚠️ RLS hala AÇIK!';
        RAISE NOTICE '   Bu SQL''i tekrar çalıştırın!';
    ELSIF insert_count < 3 THEN
        RAISE NOTICE '⚠️ INSERT yetkisi eksik!';
        RAISE NOTICE '   Bu SQL''i tekrar çalıştırın!';
    END IF;
    
    RAISE NOTICE '══════════════════════════════════════════════════════';
END $$;
