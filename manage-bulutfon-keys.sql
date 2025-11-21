-- Birden fazla kulüp için Bulutfon API Key ekleme
-- Her kulüp kendi API key'ini girecek
-- settings tablosu, data kolonu JSONB formatında

-- KULÜP 1: Atakum Tenis Kulübü
UPDATE settings
SET data = jsonb_set(
    COALESCE(data, '{}'::jsonb),
    '{bulutfonApiKey}',
    '"qEtv33s3Ys6E5Rf_lknNuisaWn2X65DP_zCgIiKllzASeqmzNATVwxHB6-t-HOsmSho"'
)
WHERE "clubId" = 'FmvoFvTCek44CR3pS4XC';

-- KULÜP 2: Örnek başka bir kulüp (varsa)
-- UPDATE settings
-- SET data = jsonb_set(
--     COALESCE(data, '{}'::jsonb),
--     '{bulutfonApiKey}',
--     '"DIGER_KULUP_API_KEY_BURAYA"'
-- )
-- WHERE "clubId" = 'DIGER_KULUP_ID';

-- Tüm kulüplerin API key durumunu kontrol
SELECT 
    c.id,
    c.name as "Kulüp Adı",
    s.data->>'bulutfonApiKey' as "Bulutfon API Key",
    CASE 
        WHEN s.data->>'bulutfonApiKey' IS NOT NULL AND s.data->>'bulutfonApiKey' != '' 
        THEN '✅ API Key Var' 
        ELSE '❌ API Key Yok' 
    END as "Bulutfon Durumu",
    (s.data->>'workingHoursEnabled')::boolean as "Mesai Saati Aktif"
FROM clubs c
LEFT JOIN settings s ON c.id = s."clubId"
WHERE c.active = true
ORDER BY c.name;
