-- WhatsApp cihazlarını kontrol et
SELECT 
    "instanceName",
    "phoneNumber",
    status,
    "clubId"
FROM "whatsappDevices"
WHERE "clubId" = 'FmvoFvTCek44CR3pS4XC'
ORDER BY "createdAt" DESC;
