-- WhatsApp Packages tablosuna SuperAdmin için UPDATE/INSERT/DELETE policy'leri ekle

-- Önce mevcut policy'leri kontrol et
SELECT policyname, cmd FROM pg_policies WHERE tablename = 'whatsapp_packages';

-- SuperAdmin tüm paketleri görebilir (mevcut policy sadece is_active=true olanları gösteriyor)
DROP POLICY IF EXISTS "Aktif paketler herkes tarafından görülebilir" ON whatsapp_packages;

CREATE POLICY "Tüm paketler görülebilir" 
ON whatsapp_packages FOR SELECT 
USING (true);

-- SuperAdmin paketleri güncelleyebilir
CREATE POLICY "SuperAdmin paket güncelleyebilir" 
ON whatsapp_packages FOR UPDATE 
USING (true)
WITH CHECK (true);

-- SuperAdmin yeni paket ekleyebilir
CREATE POLICY "SuperAdmin paket ekleyebilir" 
ON whatsapp_packages FOR INSERT 
WITH CHECK (true);

-- SuperAdmin paket silebilir
CREATE POLICY "SuperAdmin paket silebilir" 
ON whatsapp_packages FOR DELETE 
USING (true);

-- Kontrol: Tüm policy'leri listele
SELECT policyname, cmd, qual, with_check 
FROM pg_policies 
WHERE tablename = 'whatsapp_packages';
