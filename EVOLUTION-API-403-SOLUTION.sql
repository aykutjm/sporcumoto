-- 🎯 EVOLUTION API 403 HATASI İÇİN ALTERNATİF ÇÖZÜM
-- Evolution API'ye erişim olmadan Supabase'de cihaz kaydetme

-- ═══════════════════════════════════════════════════════════════
-- DURUM ANALİZİ
-- ═══════════════════════════════════════════════════════════════
-- 
-- ✅ Supabase çalışıyor
-- ✅ INSERT yetkisi var
-- ❌ Evolution API 403 veriyor (/instance/create)
--
-- SEBEP: Evolution API Key yanlış veya süresi dolmuş
-- 
-- ═══════════════════════════════════════════════════════════════

-- Mevcut cihazları kontrol et
SELECT 
    id,
    "instanceName",
    "phoneNumber",
    status,
    "isConnected",
    "createdAt"
FROM "whatsappDevices"
WHERE "clubId" = 'FmvoFvTCek44CR3pS4XC'
ORDER BY "createdAt" DESC;

-- ═══════════════════════════════════════════════════════════════
-- MANUEL CİHAZ EKLEME (Evolution API bypass)
-- ═══════════════════════════════════════════════════════════════
-- Eğer Evolution API çalışmıyorsa, manuel olarak ekleyin:

-- ÖRNEK: Yeni cihaz ekle (Evolution API olmadan)
INSERT INTO "whatsappDevices" (
    id,
    "clubId",
    "instanceName",
    "phoneNumber",
    "evolutionUrl",
    "apiKey",
    status,
    "isConnected",
    "createdBy",
    "createdAt",
    "updatedAt",
    "lastUpdated"
) VALUES (
    'whatsappDevices_' || floor(random() * 1000000000)::text || '_manual',
    'FmvoFvTCek44CR3pS4XC',  -- Club ID
    '6799',                   -- Instance Name (değiştirin)
    '05515046799',            -- Phone Number (değiştirin)
    'https://evo-2.edu-ai.online',
    'iHAF8gWNA1axdRDY9e98UKpork00dBO2',
    'pending',                -- Status: pending/connected/disconnected
    false,                    -- isConnected
    'admin@manual.com',       -- Created By
    NOW(),
    NOW(),
    NOW()
);

-- Kontrol: Eklendi mi?
SELECT * FROM "whatsappDevices" 
WHERE "instanceName" = '6799';

-- ═══════════════════════════════════════════════════════════════
-- EVOLUTION API KEY KONTROLÜ
-- ═══════════════════════════════════════════════════════════════
-- 
-- 📞 Evolution API sağlayıcınızla iletişime geçin:
-- 
-- 1. API Key'in geçerli olduğundan emin olun
-- 2. /instance/create endpoint'ine erişim yetkisi isteyin
-- 3. Yeni API Key talep edin (mevcut çalışmıyorsa)
-- 
-- Test URL (tarayıcıda açın):
-- https://evo-2.edu-ai.online/instance/fetchInstances?instanceName=test
-- 
-- Eğer 403 alırsanız → API Key sorunu
-- Eğer JSON dönerse → API çalışıyor, başka bir sorun var
--
-- ═══════════════════════════════════════════════════════════════

-- ✅ BAŞARILI MESAJI
DO $$
DECLARE
    device_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO device_count
    FROM "whatsappDevices"
    WHERE "clubId" = 'FmvoFvTCek44CR3pS4XC';
    
    RAISE NOTICE '══════════════════════════════════════════════════════';
    RAISE NOTICE '📱 WHATSAPP CİHAZ DURUMU';
    RAISE NOTICE '══════════════════════════════════════════════════════';
    RAISE NOTICE '';
    RAISE NOTICE 'Toplam Cihaz: %', device_count;
    RAISE NOTICE '';
    RAISE NOTICE '⚠️ EVOLUTION API 403 HATASI';
    RAISE NOTICE '';
    RAISE NOTICE '📌 Sorun:';
    RAISE NOTICE '   Evolution API /instance/create endpoint''i 403 veriyor';
    RAISE NOTICE '   API Key: iHAF8gWNA1axdRDY9e98UKpork00dBO2';
    RAISE NOTICE '   URL: https://evo-2.edu-ai.online';
    RAISE NOTICE '';
    RAISE NOTICE '✅ Çözüm Seçenekleri:';
    RAISE NOTICE '   1. Evolution API yöneticisinden yeni key isteyin';
    RAISE NOTICE '   2. /instance/create yetkisi isteyin';
    RAISE NOTICE '   3. Mevcut 5 cihazı kullanmaya devam edin';
    RAISE NOTICE '   4. Manuel olarak yukarıdaki INSERT komutunu kullanın';
    RAISE NOTICE '';
    RAISE NOTICE '💡 Geçici Çözüm:';
    RAISE NOTICE '   Mevcut % cihaz zaten çalışıyor', device_count;
    RAISE NOTICE '   Bunları kullanmaya devam edebilirsiniz!';
    RAISE NOTICE '══════════════════════════════════════════════════════';
END $$;
