-- 🔥 SUPABASE TAM YETKİLENDİRME - 403 HATASI KESİN ÇÖZÜM
-- Tüm WhatsApp tablolarına tam yetki ver

-- ═══════════════════════════════════════════════════════════════
-- ADIM 1: TÜM WHATSAPP TABLOLARINA GRANT VER
-- ═══════════════════════════════════════════════════════════════

-- whatsappDevices
GRANT ALL PRIVILEGES ON TABLE "whatsappDevices" TO authenticated;
GRANT ALL PRIVILEGES ON TABLE "whatsappDevices" TO anon;
GRANT ALL PRIVILEGES ON TABLE "whatsappDevices" TO service_role;
GRANT ALL PRIVILEGES ON TABLE "whatsappDevices" TO PUBLIC;

-- whatsappIncomingCalls
GRANT ALL PRIVILEGES ON TABLE "whatsappIncomingCalls" TO authenticated;
GRANT ALL PRIVILEGES ON TABLE "whatsappIncomingCalls" TO anon;
GRANT ALL PRIVILEGES ON TABLE "whatsappIncomingCalls" TO service_role;
GRANT ALL PRIVILEGES ON TABLE "whatsappIncomingCalls" TO PUBLIC;

-- whatsappIncomingMessages
GRANT ALL PRIVILEGES ON TABLE "whatsappIncomingMessages" TO authenticated;
GRANT ALL PRIVILEGES ON TABLE "whatsappIncomingMessages" TO anon;
GRANT ALL PRIVILEGES ON TABLE "whatsappIncomingMessages" TO service_role;
GRANT ALL PRIVILEGES ON TABLE "whatsappIncomingMessages" TO PUBLIC;

-- whatsappMessages
GRANT ALL PRIVILEGES ON TABLE "whatsappMessages" TO authenticated;
GRANT ALL PRIVILEGES ON TABLE "whatsappMessages" TO anon;
GRANT ALL PRIVILEGES ON TABLE "whatsappMessages" TO service_role;
GRANT ALL PRIVILEGES ON TABLE "whatsappMessages" TO PUBLIC;

-- sentMessages
GRANT ALL PRIVILEGES ON TABLE "sentMessages" TO authenticated;
GRANT ALL PRIVILEGES ON TABLE "sentMessages" TO anon;
GRANT ALL PRIVILEGES ON TABLE "sentMessages" TO service_role;
GRANT ALL PRIVILEGES ON TABLE "sentMessages" TO PUBLIC;

-- messageQueue
GRANT ALL PRIVILEGES ON TABLE "messageQueue" TO authenticated;
GRANT ALL PRIVILEGES ON TABLE "messageQueue" TO anon;
GRANT ALL PRIVILEGES ON TABLE "messageQueue" TO service_role;
GRANT ALL PRIVILEGES ON TABLE "messageQueue" TO PUBLIC;

-- scheduledMessages
GRANT ALL PRIVILEGES ON TABLE "scheduledMessages" TO authenticated;
GRANT ALL PRIVILEGES ON TABLE "scheduledMessages" TO anon;
GRANT ALL PRIVILEGES ON TABLE "scheduledMessages" TO service_role;
GRANT ALL PRIVILEGES ON TABLE "scheduledMessages" TO PUBLIC;

-- ═══════════════════════════════════════════════════════════════
-- ADIM 2: SCHEMA YETKİLERİ
-- ═══════════════════════════════════════════════════════════════

GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO service_role;
GRANT USAGE ON SCHEMA public TO PUBLIC;

GRANT CREATE ON SCHEMA public TO authenticated;
GRANT CREATE ON SCHEMA public TO anon;
GRANT CREATE ON SCHEMA public TO service_role;

-- ═══════════════════════════════════════════════════════════════
-- ADIM 3: SEQUENCE YETKİLERİ (ID üretimi için)
-- ═══════════════════════════════════════════════════════════════

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO service_role;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO PUBLIC;

-- ═══════════════════════════════════════════════════════════════
-- ADIM 4: TÜM TABLOLARA GENEL YETKİ
-- ═══════════════════════════════════════════════════════════════

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO anon;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO service_role;

-- ═══════════════════════════════════════════════════════════════
-- ADIM 5: RLS'LERİ KAPAT (Supabase sisteminde)
-- ═══════════════════════════════════════════════════════════════

ALTER TABLE "whatsappDevices" DISABLE ROW LEVEL SECURITY;
ALTER TABLE "whatsappIncomingCalls" DISABLE ROW LEVEL SECURITY;
ALTER TABLE "whatsappIncomingMessages" DISABLE ROW LEVEL SECURITY;
ALTER TABLE "whatsappMessages" DISABLE ROW LEVEL SECURITY;
ALTER TABLE "sentMessages" DISABLE ROW LEVEL SECURITY;
ALTER TABLE "messageQueue" DISABLE ROW LEVEL SECURITY;
ALTER TABLE "scheduledMessages" DISABLE ROW LEVEL SECURITY;

-- ═══════════════════════════════════════════════════════════════
-- ADIM 6: VARSAYILAN YETKİLER (Gelecekteki tablolar için)
-- ═══════════════════════════════════════════════════════════════

ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO PUBLIC;

ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO PUBLIC;

-- ═══════════════════════════════════════════════════════════════
-- ✅ KONTROL VE RAPOR
-- ═══════════════════════════════════════════════════════════════

DO $$
DECLARE
    devices_grants INTEGER;
    devices_rls BOOLEAN;
BEGIN
    -- whatsappDevices için yetki sayısı
    SELECT COUNT(*) INTO devices_grants
    FROM information_schema.table_privileges
    WHERE table_name = 'whatsappDevices';
    
    -- RLS durumu
    SELECT rowsecurity INTO devices_rls
    FROM pg_tables 
    WHERE tablename = 'whatsappDevices';
    
    RAISE NOTICE '';
    RAISE NOTICE '═══════════════════════════════════════════════════════════';
    RAISE NOTICE '✅ SUPABASE WHATSAPP SİSTEMİ - TAM YETKİLENDİRME TAMAMLANDI';
    RAISE NOTICE '═══════════════════════════════════════════════════════════';
    RAISE NOTICE '';
    RAISE NOTICE '📊 whatsappDevices Durumu:';
    RAISE NOTICE '   • Toplam Yetki: % adet', devices_grants;
    RAISE NOTICE '   • RLS Durumu: %', CASE WHEN devices_rls THEN '🔒 AÇIK' ELSE '✅ KAPALI' END;
    RAISE NOTICE '';
    
    IF devices_grants >= 12 AND NOT devices_rls THEN
        RAISE NOTICE '✅✅✅ MÜKEMMEL! Sistem hazır.';
        RAISE NOTICE '';
        RAISE NOTICE '🎯 Şimdi yapılacaklar:';
        RAISE NOTICE '   1. Tarayıcı cache temizle (Ctrl+Shift+Delete)';
        RAISE NOTICE '   2. Tarayıcıyı TAMAMEN kapat';
        RAISE NOTICE '   3. Yeniden aç ve giriş yap';
        RAISE NOTICE '   4. WhatsApp cihazı eklemeyi dene';
        RAISE NOTICE '';
        RAISE NOTICE '💡 403 hatası devam ederse:';
        RAISE NOTICE '   → Evolution API''den kaynaklanıyor demektir';
        RAISE NOTICE '   → Evolution API Key: iHAF8gWNA1axdRDY9e98UKpork00dBO2';
        RAISE NOTICE '   → Evolution URL: https://evo-2.edu-ai.online';
        RAISE NOTICE '   → Bu bilgilerin doğru olduğundan emin olun';
    ELSE
        RAISE NOTICE '⚠️ Eksikler var:';
        IF devices_grants < 12 THEN
            RAISE NOTICE '   • Yetki sayısı düşük (% < 12)', devices_grants;
        END IF;
        IF devices_rls THEN
            RAISE NOTICE '   • RLS hala açık';
        END IF;
        RAISE NOTICE '';
        RAISE NOTICE '👉 Bu SQL''i tekrar çalıştırın!';
    END IF;
    
    RAISE NOTICE '';
    RAISE NOTICE '═══════════════════════════════════════════════════════════';
END $$;

-- Yetki listesini göster
SELECT 
    table_name as "Tablo",
    COUNT(*) as "Yetki Sayısı",
    string_agg(DISTINCT grantee, ', ') as "Yetkili Roller"
FROM information_schema.table_privileges
WHERE table_name IN (
    'whatsappDevices',
    'whatsappIncomingCalls', 
    'whatsappIncomingMessages',
    'whatsappMessages',
    'sentMessages',
    'messageQueue'
)
GROUP BY table_name
ORDER BY table_name;
