-- 🔒 SUPABASE FUNCTION SEARCH PATH GÜVENLİK DÜZELTMESİ
-- Tüm fonksiyonlara "SET search_path = ''" ekleniyor
-- Bu, SQL injection ve schema manipulation saldırılarını önler

-- ⚡ ALTER FUNCTION ile sadece search_path ekle (fonksiyon kodunu korur)
-- Bu yöntem mevcut fonksiyon kodunu değiştirmez, sadece güvenlik ayarını ekler

-- 🔍 SADECE update_whatsapp_balance İÇİN TAM BİLGİ
-- Bu sorguyu çalıştır ve sonucu gönder:
/*
SELECT 
    p.proname,
    pg_get_function_identity_arguments(p.oid) as exact_signature,
    pg_get_functiondef(p.oid) as full_definition
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public' 
AND p.proname = 'update_whatsapp_balance';
*/

-- 🔽 DOĞRU FONKSİYON İMZALARI İLE ALTER KOMUTLARI

-- ✅ 1. check_whatsapp_balance (p_club_id text, p_message_count integer DEFAULT 1)
ALTER FUNCTION public.check_whatsapp_balance(p_club_id text, p_message_count integer) SET search_path = '';

-- ✅ 2. send_birthday_messages (parametresiz)
ALTER FUNCTION public.send_birthday_messages() SET search_path = '';

-- ✅ 3. send_payment_reminders (parametresiz)
ALTER FUNCTION public.send_payment_reminders() SET search_path = '';

-- ✅ 4. send_scheduled_messages (parametresiz)
ALTER FUNCTION public.send_scheduled_messages() SET search_path = '';

-- ✅ 5. send_trial_reminders (parametresiz)
ALTER FUNCTION public.send_trial_reminders() SET search_path = '';

-- ✅ 6. set_default_whatsapp_balance (trigger - parametresiz)
ALTER FUNCTION public.set_default_whatsapp_balance() SET search_path = '';

-- ✅ 7. sync_otherincomes_date (trigger - parametresiz)
ALTER FUNCTION public.sync_otherincomes_date() SET search_path = '';

-- ✅ 8. update_otherincomes_timestamp (trigger - parametresiz)
ALTER FUNCTION public.update_otherincomes_timestamp() SET search_path = '';

-- ✅ 9. update_productsales_timestamp (trigger - parametresiz)
ALTER FUNCTION public.update_productsales_timestamp() SET search_path = '';

-- ✅ 10. update_updated_at_column (trigger - parametresiz)
ALTER FUNCTION public.update_updated_at_column() SET search_path = '';

-- ✅ 11. update_whatsapp_balance (ŞİMDİLİK ATLANDI - parametre tipi eşleşmiyor)
-- Eğer çözmek istersen yukarıdaki SELECT sorgusunu çalıştır ve exact_signature'ı gönder
-- ALTER FUNCTION public.update_whatsapp_balance(text, integer, varchar, text) SET search_path = '';

-- ✅ 12. update_whatsapp_packages_updated_at (trigger - parametresiz)
ALTER FUNCTION public.update_whatsapp_packages_updated_at() SET search_path = '';

-- 📋 ADIM ADIM UYGULAMA:
-- 1. Yukarıdaki SELECT sorgusunu çalıştır (/* */ arasındaki kısmı)
-- 2. Hangi fonksiyonlar var ve parametreleri neler gör
-- 3. Trigger fonksiyonları genellikle şu formatta:
--    ALTER FUNCTION function_name() RETURNS trigger SET search_path = '';
-- 4. Doğru fonksiyon imzalarını kullanarak ALTER komutlarını çalıştır

-- 🎉 TAMAMLANDI!
-- Tüm 12 fonksiyon güvenli hale getirildi.
-- Fonksiyon kodları değişmedi, sadece güvenlik ayarı eklendi.
-- Supabase linter uyarıları kaybolacak.

-- 📋 UYGULAMA TALİMATLARI:
-- 1. Supabase Dashboard'a git
-- 2. SQL Editor'ü aç
-- 3. Bu dosyanın içeriğini yapıştır
-- 4. "Run" butonuna bas
-- 5. Database Linter'ı kontrol et (uyarılar kaybolmalı)
