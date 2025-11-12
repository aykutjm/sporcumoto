-- ============================================
-- TÜM KULÜPLER İÇİN BRANŞLARI SUPABASE'E EKLE
-- ============================================
-- Bu script, kulüplerin branşlarını Supabase branches tablosuna 
-- eklemek için örnek SQL'ler içerir
-- NOT: Admin panelinden eklenen tüm branşlar artık otomatik olarak 
-- Supabase'e kaydedilir (Firebase kaldırıldı)

-- ============================================
-- 1. KADİRLİ TENİS KULÜBÜ
-- ============================================
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
    'branch_kadirli_tenis_' || floor(random() * 1000000)::text,
    'clubs_1762416794386_zsy81f5v7',
    'tenis',
    'Tenis',
    '🎾',
    '#4CAF50',
    '[]'::jsonb,
    true,
    NOW(),
    NOW()
) ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 2. ATAKUM TENİS KULÜBÜ
-- ============================================
-- NOT: Atakum Tenis Kulübü'nün ID'sini clubs tablosundan bulmanız gerekiyor
-- Aşağıdaki sorguyu çalıştırarak ID'yi bulabilirsiniz:
-- SELECT id, name FROM clubs WHERE name ILIKE '%atakum%';

-- Örnek (ID'yi bulup yerine koyun):
-- INSERT INTO branches (
--     id,
--     "clubId",
--     "branchId",
--     "branchName",
--     icon,
--     color,
--     courts,
--     "isActive",
--     "createdAt",
--     "updatedAt"
-- ) VALUES 
--     ('branch_atakum_tenis_' || floor(random() * 1000000)::text, 'clubs_XXXX', 'tenis', 'Tenis', '🎾', '#4CAF50', '[]'::jsonb, true, NOW(), NOW()),
--     ('branch_atakum_yuzme_' || floor(random() * 1000000)::text, 'clubs_XXXX', 'yuzme', 'Yüzme', '🏊', '#2196F3', '[]'::jsonb, true, NOW(), NOW())
-- ON CONFLICT (id) DO NOTHING;

-- ============================================
-- TÜM AKTİF KULÜPLER LİSTESİ
-- ============================================
-- Tüm aktif kulüpleri listele (ID'lerini bulmak için):
SELECT 
    id as "clubId",
    name as "clubName",
    slug as "clubSlug"
FROM clubs
WHERE status = 'active' OR status IS NULL
ORDER BY name;

-- ============================================
-- SUPABASE'DEKİ MEVCUT BRANŞLARI KONTROL ET
-- ============================================
-- Hangi kulüplerin branşı var, hangilerinin yok kontrol et:
SELECT 
    c.id as "clubId",
    c.name as "clubName",
    COUNT(b.id) as "branchCount",
    STRING_AGG(b."branchName", ', ') as "branches"
FROM clubs c
LEFT JOIN branches b ON b."clubId" = c.id AND b."isActive" = true
WHERE c.status = 'active' OR c.status IS NULL
GROUP BY c.id, c.name
ORDER BY c.name;

-- ============================================
-- BRANŞ OLMAYAN KULÜPLER
-- ============================================
-- Hangi kulüplerin henüz branşı yok?
SELECT 
    c.id as "clubId",
    c.name as "clubName"
FROM clubs c
LEFT JOIN branches b ON b."clubId" = c.id AND b."isActive" = true
WHERE (c.status = 'active' OR c.status IS NULL)
  AND b.id IS NULL
ORDER BY c.name;

-- ============================================
-- TOPLU BRANŞ EKLEME ŞABLONNu
-- ============================================
-- Her kulüp için aşağıdaki şablonu kullanarak branş ekleyebilirsiniz:

/*
-- KULÜP ADI: [Kulüp Adını Buraya Yazın]
-- KULÜP ID: [clubs_xxx]
INSERT INTO branches (id, "clubId", "branchId", "branchName", icon, color, courts, "isActive", "createdAt", "updatedAt")
VALUES 
    ('branch_[kulup]_tenis_' || floor(random() * 1000000)::text, '[clubId]', 'tenis', 'Tenis', '🎾', '#4CAF50', '[]'::jsonb, true, NOW(), NOW()),
    ('branch_[kulup]_yuzme_' || floor(random() * 1000000)::text, '[clubId]', 'yuzme', 'Yüzme', '🏊', '#2196F3', '[]'::jsonb, true, NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
*/

-- ============================================
-- VARSAYILAN İKONLAR ve RENKLER
-- ============================================
-- Tenis: 🎾 #4CAF50 (Yeşil)
-- Yüzme: 🏊 #2196F3 (Mavi)
-- Futbol: ⚽ #FF9800 (Turuncu)
-- Basketbol: 🏀 #F44336 (Kırmızı)
-- Voleybol: 🏐 #9C27B0 (Mor)
-- Badminton: 🏸 #FFEB3B (Sarı)
-- Masa Tenisi: 🏓 #00BCD4 (Camgöbeği)
-- Jimnastik: 🤸 #E91E63 (Pembe)

