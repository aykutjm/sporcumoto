-- WhatsApp Cihazlar tablosunun tüm kolonlarını göster
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'whatsappDevices' 
ORDER BY ordinal_position;
