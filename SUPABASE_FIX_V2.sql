-- HIZLI FIX V2: Sadece eksik olanları ekle

-- 1. is_popular kolonu ekle (eğer yoksa)
ALTER TABLE whatsapp_packages 
ADD COLUMN IF NOT EXISTS is_popular BOOLEAN DEFAULT false;

-- 2. Eksik policy'leri ekle (DROP IF EXISTS ile güvenli)

-- UPDATE policy
DROP POLICY IF EXISTS "SuperAdmin paket güncelleyebilir" ON whatsapp_packages;
CREATE POLICY "SuperAdmin paket güncelleyebilir" 
ON whatsapp_packages FOR UPDATE 
USING (true) WITH CHECK (true);

-- INSERT policy
DROP POLICY IF EXISTS "SuperAdmin paket ekleyebilir" ON whatsapp_packages;
CREATE POLICY "SuperAdmin paket ekleyebilir" 
ON whatsapp_packages FOR INSERT 
WITH CHECK (true);

-- DELETE policy
DROP POLICY IF EXISTS "SuperAdmin paket silebilir" ON whatsapp_packages;
CREATE POLICY "SuperAdmin paket silebilir" 
ON whatsapp_packages FOR DELETE 
USING (true);

-- 3. Kontrol
SELECT id, name, message_count, price, is_active, is_popular 
FROM whatsapp_packages 
ORDER BY message_count;
