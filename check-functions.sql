-- Mevcut fonksiyonları kontrol et
SELECT 
    p.proname as "Function Name",
    pg_get_functiondef(p.oid) as "Function Definition"
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
    AND p.proname IN ('check_whatsapp_balance', 'update_whatsapp_balance');
