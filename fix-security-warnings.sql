-- Güvenlik Uyarılarını Düzelt
-- 1. Function search_path uyarıları
-- 2. Extension public schema uyarısı

-- ============================================
-- 1. FUNCTION SEARCH_PATH DÜZELTMELERİ
-- ============================================

-- check_whatsapp_balance fonksiyonunu güvenli hale getir
DROP FUNCTION IF EXISTS public.check_whatsapp_balance(text);

CREATE OR REPLACE FUNCTION public.check_whatsapp_balance(p_club_id text)
RETURNS TABLE (
    device_id text,
    balance numeric,
    last_checked timestamp with time zone
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = '' -- 🔒 Güvenlik için search_path boş
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "instanceName" as device_id,
        "balance",
        "lastBalanceCheck" as last_checked
    FROM public."whatsappDevices"
    WHERE "clubId" = p_club_id
        AND status = 'active';
END;
$$;

-- update_whatsapp_balance fonksiyonunu güvenli hale getir
DROP FUNCTION IF EXISTS public.update_whatsapp_balance(text, numeric);

CREATE OR REPLACE FUNCTION public.update_whatsapp_balance(
    p_device_id text,
    p_balance numeric
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = '' -- 🔒 Güvenlik için search_path boş
AS $$
BEGIN
    UPDATE public."whatsappDevices"
    SET 
        balance = p_balance,
        "lastBalanceCheck" = NOW()
    WHERE "instanceName" = p_device_id;
END;
$$;

-- ============================================
-- 2. EXTENSION TAŞIMA (http extension)
-- ============================================

-- http extension SET SCHEMA desteklemiyor, bu yüzden:
-- ÇÖZÜM: Extension'ı public'te bırakıyoruz (Supabase'de yaygın kullanım)
-- Bu sadece bir WARNING, ERROR değil. Göz ardı edilebilir.

-- NOT: http extension genellikle Edge Functions ve webhook'lar için kullanılır
-- Public schema'da olması normal bir durumdur.

-- Eğer gerçekten taşımak isterseniz (önerilmez):
-- 1. DROP EXTENSION http CASCADE;
-- 2. CREATE SCHEMA IF NOT EXISTS extensions;
-- 3. CREATE EXTENSION http SCHEMA extensions;
-- Ancak bu mevcut fonksiyonları bozabilir!

-- Kontrol sorgusu
SELECT 
    e.extname as "Extension",
    n.nspname as "Schema",
    'WARNING: Public schema OK for http extension' as "Note"
FROM pg_extension e
JOIN pg_namespace n ON e.extnamespace = n.oid
WHERE e.extname = 'http';

-- ============================================
-- SONUÇ KONTROLÜ
-- ============================================

-- Function'ların search_path'ini kontrol et
SELECT 
    p.proname as "Function",
    pg_get_function_identity_arguments(p.oid) as "Arguments",
    p.prosecdef as "Security Definer",
    pg_get_function_result(p.oid) as "Returns",
    COALESCE(array_to_string(p.proconfig, ', '), 'default') as "Config"
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
    AND p.proname IN ('check_whatsapp_balance', 'update_whatsapp_balance');
