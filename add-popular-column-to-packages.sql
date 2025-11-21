-- WhatsApp Packages tablosuna is_popular kolonu ekle

ALTER TABLE whatsapp_packages 
ADD COLUMN IF NOT EXISTS is_popular BOOLEAN DEFAULT false;

-- Mevcut "Profesyonel Paket" (5000 mesaj) paketini popüler yap
UPDATE whatsapp_packages 
SET is_popular = true 
WHERE message_count = 5000;

-- Kontrol: Tüm paketleri göster
SELECT id, name, message_count, price, is_active, is_popular 
FROM whatsapp_packages 
ORDER BY message_count;
