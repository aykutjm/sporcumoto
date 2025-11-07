-- ============================================
-- SETTINGS TABLOSUNA data SÜTUNU EKLE
-- ============================================

-- Eğer data sütunu yoksa ekle (JSONB)
ALTER TABLE settings 
ADD COLUMN IF NOT EXISTS "data" JSONB DEFAULT '{}'::jsonb;

-- Başarılı mesaj
SELECT 
    'data sütunu başarıyla eklendi veya zaten mevcut!' as status,
    COUNT(*) as total_settings
FROM settings;

