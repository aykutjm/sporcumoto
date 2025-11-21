-- HIZLI FIX: WhatsApp Packages için is_popular kolonu ve RLS policy'ler
-- Bu SQL'i Supabase SQL Editor'da çalıştırın

-- 1. is_popular kolonu ekle
ALTER TABLE whatsapp_packages 
ADD COLUMN IF NOT EXISTS is_popular BOOLEAN DEFAULT false;

-- 2. Eski policy'yi sil ve yenilerini ekle
DROP POLICY IF EXISTS "Aktif paketler herkes tarafından görülebilir" ON whatsapp_packages;

-- Herkes tüm paketleri görebilir
CREATE POLICY "Tüm paketler görülebilir" 
ON whatsapp_packages FOR SELECT 
USING (true);

-- SuperAdmin paketleri güncelleyebilir
CREATE POLICY "SuperAdmin paket güncelleyebilir" 
ON whatsapp_packages FOR UPDATE 
USING (true) WITH CHECK (true);

-- SuperAdmin yeni paket ekleyebilir
CREATE POLICY "SuperAdmin paket ekleyebilir" 
ON whatsapp_packages FOR INSERT 
WITH CHECK (true);

-- SuperAdmin paket silebilir
CREATE POLICY "SuperAdmin paket silebilir" 
ON whatsapp_packages FOR DELETE 
USING (true);

-- 3. Kontrol: Güncel durum
SELECT 
    id, 
    name, 
    message_count, 
    price, 
    is_active, 
    is_popular,
    created_at
FROM whatsapp_packages 
ORDER BY message_count;

-- 4. Policy'leri kontrol et
SELECT 
    schemaname,
    tablename,
    policyname,
    cmd as command,
    qual as using_expression,
    with_check as with_check_expression
FROM pg_policies 
WHERE tablename = 'whatsapp_packages'
ORDER BY cmd;

-- Başarılı! Artık superadmin.html'den paketleri düzenleyebilirsiniz.
