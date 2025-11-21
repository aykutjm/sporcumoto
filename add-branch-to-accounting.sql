-- ================================
-- ÜYELERİN BRANŞ BİLGİSİNİ NORMALIZE ET
-- ================================

-- 1️⃣ Büyük harfle başlayan "Tenis" → küçük harf "tenis" yap
UPDATE members
SET "Brans" = LOWER("Brans")
WHERE "clubId" = 'FmvoFvTCek44CR3pS4XC'
  AND "Brans" IS NOT NULL
  AND "Brans" != LOWER("Brans");

-- 2️⃣ Kontrol: Düzeltme sonrası Brans değerleri
SELECT 
    "Brans",
    COUNT(*) as "Üye Sayısı"
FROM members
WHERE "clubId" = 'FmvoFvTCek44CR3pS4XC'
GROUP BY "Brans"
ORDER BY COUNT(*) DESC;

-- 3️⃣ Yüzme üyelerini listele (test için)
SELECT 
    "Ad_Soyad",
    "Brans",
    status
FROM members
WHERE "clubId" = 'FmvoFvTCek44CR3pS4XC'
  AND "Brans" = 'yuzme'
LIMIT 5;
