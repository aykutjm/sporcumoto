-- Tablo isimlerini kontrol et
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name ILIKE '%setting%'
ORDER BY table_name;

-- Clubs tablosunun kolonlarını kontrol et
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'clubs'
  AND table_schema = 'public'
ORDER BY ordinal_position;
