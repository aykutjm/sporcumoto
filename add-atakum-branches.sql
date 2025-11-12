-- ============================================
-- ATAKUM TENİS KULÜBÜ BRANŞLARINI EKLE
-- ============================================
-- Club ID: FmvoFvTCek44CR3pS4XC (Supabase clubs tablosundan alındı)
-- ============================================

-- ============================================
-- ATAKUM TENİS KULÜBÜ İÇİN BRANŞLAR
-- ============================================

-- Tenis Branşı
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

-- Yüzme Branşı (Atakum Olimpik Havuz)
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

-- ============================================
-- KONTROL: Eklenen branşları görüntüle
-- ============================================
SELECT 
    id,
    "clubId",
    "branchId",
    "branchName",
    icon,
    color,
    "isActive",
    "createdAt"
FROM branches
WHERE "clubId" = 'FmvoFvTCek44CR3pS4XC'
ORDER BY "branchName";

-- ============================================
-- TEK KOMUTLA TÜM İŞLEMLER (ÖNERİLEN)
-- ============================================
-- Bu komutu çalıştırarak her iki branşı birden ekleyebilirsiniz:

DO $$
BEGIN
    -- Tenis branşını ekle
    INSERT INTO branches (id, "clubId", "branchId", "branchName", icon, color, courts, "isActive", "createdAt", "updatedAt")
    VALUES (
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
    )
    ON CONFLICT (id) DO NOTHING;
    
    -- Yüzme branşını ekle
    INSERT INTO branches (id, "clubId", "branchId", "branchName", icon, color, courts, "isActive", "createdAt", "updatedAt")
    VALUES (
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
    )
    ON CONFLICT (id) DO NOTHING;
    
    RAISE NOTICE '✅ Atakum Tenis Kulübü branşları başarıyla eklendi!';
END $$;

-- Son kontrol
SELECT 
    c.name as "Kulüp Adı",
    b."branchName" as "Branş",
    b.icon as "İkon",
    b."isActive" as "Aktif"
FROM clubs c
LEFT JOIN branches b ON b."clubId" = c.id
WHERE c.id = 'FmvoFvTCek44CR3pS4XC';

