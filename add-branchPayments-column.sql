-- ============================================
-- SETTINGS TABLOSUNA branchPayments SÜTUNU EKLE
-- ============================================

-- branchPayments sütunu ekle (JSONB formatında - Firebase compatible)
ALTER TABLE settings 
ADD COLUMN IF NOT EXISTS branchPayments JSONB DEFAULT '{}'::jsonb;

-- Başarı mesajı
SELECT 
    'branchPayments sütunu başarıyla eklendi veya zaten mevcut!' as status,
    COUNT(*) as total_settings
FROM settings;

-- Mevcut contract kayıtlarını kontrol et
SELECT 
    id, 
    branchPayments,
    jsonb_typeof(branchPayments) as column_type
FROM settings 
WHERE id LIKE 'contract_%'
LIMIT 5;


