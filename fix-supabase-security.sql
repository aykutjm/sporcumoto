-- Supabase Security Fix: update_updated_at_column Function
-- Bu fonksiyon mutable search_path uyarısı veriyor
-- Güvenli hale getirmek için yeniden oluşturuyoruz

-- Önce mevcut fonksiyonu kontrol et
SELECT routine_name, routine_schema 
FROM information_schema.routines 
WHERE routine_name = 'update_updated_at_column';

-- Fonksiyonu güvenli şekilde yeniden oluştur
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = '' -- ✅ Güvenlik: boş search_path
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- Açıklama ekle
COMMENT ON FUNCTION public.update_updated_at_column() IS 
'Automatically updates the updated_at column to current timestamp. Security: immutable search_path.';

-- Fonksiyonu test et
SELECT proname, prosecdef, proconfig 
FROM pg_proc 
WHERE proname = 'update_updated_at_column';

