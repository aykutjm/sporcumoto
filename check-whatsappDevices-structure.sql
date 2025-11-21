-- ✅ WhatsApp Devices Tablosu Mevcut Yapısını Kontrol Et
-- Bu sorguyu çalıştırarak tablodaki kolonları görebilirsiniz

SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'whatsappDevices'
ORDER BY ordinal_position;

-- Alternatif olarak PostgreSQL komutunu kullanabilirsiniz:
-- \d "whatsappDevices"
