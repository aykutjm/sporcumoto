-- ================================
-- YÖNETİCİLERE BRANŞ ATAMA SİSTEMİ
-- ================================

-- 1️⃣ Users tablosuna branches kolonu ekle
-- Bu kolonda yöneticinin erişebileceği branşlar saklanacak
-- Örnek: ["tenis", "futbol"] veya null (tüm branşlar)

ALTER TABLE users
ADD COLUMN IF NOT EXISTS branches JSONB DEFAULT NULL;

COMMENT ON COLUMN users.branches IS 'Yöneticinin erişebileceği branşlar. NULL = Tüm branşlar (Superadmin), Array = Belirli branşlar';

-- 1️⃣.2 Users tablosuna pageAccess kolonu ekle
ALTER TABLE users
ADD COLUMN IF NOT EXISTS "pageAccess" JSONB DEFAULT NULL;

COMMENT ON COLUMN users."pageAccess" IS 'Yöneticinin erişebileceği sayfalar. NULL = Tüm sayfalar, Object = Belirli sayfalar {"members": true, "crm": false, ...}';

-- 1️⃣.3 Users tablosuna role kolonu ekle (yoksa)
ALTER TABLE users
ADD COLUMN IF NOT EXISTS role TEXT DEFAULT NULL;

COMMENT ON COLUMN users.role IS 'Kullanıcı rolü: admin, muhasebe, antrenor, crm, viewer, vb.';

-- ✅ Mevcut tüm admin'lere otomatik olarak tüm branşları ata (NULL)
UPDATE users
SET branches = NULL
WHERE role = 'admin' OR "isSuperAdmin" = true;

-- 2️⃣ Kontrol sorguları

-- Tüm kullanıcıları ve branşlarını listele
SELECT 
    id,
    "fullName",
    email,
    role,
    "clubId",
    branches,
    "pageAccess",
    "isSuperAdmin"
FROM users
ORDER BY "clubId", role, "fullName";


-- Branş atanmış kullanıcıları listele
SELECT 
    "fullName",
    email,
    role,
    branches,
    "pageAccess"
FROM users
WHERE branches IS NOT NULL
ORDER BY "fullName";


-- 3️⃣ Test verisi (İsteğe bağlı)

-- Örnek: Bir yöneticiye tenis ve basketbol branşlarını ata
/*
UPDATE users
SET branches = '["tenis", "basketbol"]'::jsonb
WHERE email = 'yonetici@example.com';
*/

-- Örnek: Superadmin'e tüm branşları ver (NULL)
/*
UPDATE users
SET branches = NULL
WHERE "isSuperAdmin" = true;
*/


-- 4️⃣ Kullanışlı sorgular

-- Belirli bir branşa erişimi olan kullanıcıları bul
/*
SELECT 
    "fullName",
    email,
    branches
FROM users
WHERE branches @> '["tenis"]'::jsonb  -- tenis branşına erişimi olanlar
   OR branches IS NULL;  -- veya tüm branşlara erişimi olanlar (superadmin)
*/

-- Branş atanmamış (henüz kısıtlanmamış) kullanıcıları bul
SELECT 
    "fullName",
    email,
    role,
    branches
FROM users
WHERE branches IS NULL
  AND "isSuperAdmin" = false;  -- Superadmin değil ama branches NULL (herkese açık)
