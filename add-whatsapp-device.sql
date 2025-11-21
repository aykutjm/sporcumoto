-- Mevcut WhatsApp cihazını Supabase'e ekle
-- Evolution API'de zaten var: Kulup (903623630064)

-- Önce mevcut kaydı sil (varsa)
DELETE FROM "whatsappDevices"
WHERE "instanceName" = 'Kulup';

-- Yeni kayıt ekle
INSERT INTO "whatsappDevices" (
    id,
    "instanceName",
    "phoneNumber",
    "clubId",
    status,
    "createdAt",
    "updatedAt"
)
VALUES (
    gen_random_uuid(),
    'Kulup',
    '903623630064',
    'FmvoFvTCek44CR3pS4XC',
    'active',
    NOW(),
    NOW()
);

-- Kontrol
SELECT 
    id,
    "instanceName",
    "phoneNumber",
    status,
    "clubId"
FROM "whatsappDevices"
WHERE "clubId" = 'FmvoFvTCek44CR3pS4XC';
