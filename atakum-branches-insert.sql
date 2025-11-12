-- ATAKUM TENİS KULÜBÜ BRANŞLARINI EKLE
-- Club ID: FmvoFvTCek44CR3pS4XC

-- Tenis Branşı Ekle
INSERT INTO branches (
    id,
    "clubId",
    "branchId",
    "branchName",
    icon,
    color,
    courts,
    "isActive",
    "createdAt",
    "updatedAt"
) VALUES (
    'branch_atakum_tenis_' || floor(random() * 1000000)::text,
    'FmvoFvTCek44CR3pS4XC',
    'tenis',
    'Tenis',
    '🎾',
    '#4CAF50',
    '[]'::jsonb,
    true,
    NOW(),
    NOW()
) ON CONFLICT (id) DO NOTHING;

-- Yüzme Branşı Ekle
INSERT INTO branches (
    id,
    "clubId",
    "branchId",
    "branchName",
    icon,
    color,
    courts,
    "isActive",
    "createdAt",
    "updatedAt"
) VALUES (
    'branch_atakum_yuzme_' || floor(random() * 1000000)::text,
    'FmvoFvTCek44CR3pS4XC',
    'yuzme',
    'Yüzme',
    '🏊',
    '#2196F3',
    '[]'::jsonb,
    true,
    NOW(),
    NOW()
) ON CONFLICT (id) DO NOTHING;

-- Kontrol Et
SELECT 
    "branchId",
    "branchName",
    icon,
    "isActive"
FROM branches
WHERE "clubId" = 'FmvoFvTCek44CR3pS4XC'
ORDER BY "branchName";

