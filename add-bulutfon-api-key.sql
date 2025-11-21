-- clubSettings'e Bulutfon API Key ekle
-- Atakum Tenis Kulübü için

UPDATE "clubSettings"
SET "bulutfonApiKey" = 'BURAYA_BULUTFON_API_KEY_EKLEYIN'
WHERE "clubId" = 'FmvoFvTCek44CR3pS4XC';

-- Kontrol
SELECT 
    "clubId",
    "bulutfonApiKey",
    "workingHoursEnabled",
    "workingHoursStart",
    "workingHoursEnd"
FROM "clubSettings"
WHERE "clubId" = 'FmvoFvTCek44CR3pS4XC';
