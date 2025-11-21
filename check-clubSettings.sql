-- Mevcut clubSettings'i kontrol et
SELECT 
    "clubId",
    "bulutfonApiKey",
    "workingHoursEnabled",
    "workingHoursStart",
    "workingHoursEnd",
    "workingDays"
FROM "clubSettings"
WHERE "clubId" = 'FmvoFvTCek44CR3pS4XC';
