-- ============================================================
-- SUPABASE GÜVENLİK VE PERFORMANS OPTİMİZASYONU
-- ============================================================
-- Bu script 2 ana sorunu çözer:
-- 1. HTTP extension güvenlik uyarısı (public schema'dan taşı)
-- 2. RLS policy performans sorunu (auth.uid() optimizasyonu)
-- ============================================================

-- ============================================================
-- BÖLÜM 1: HTTP EXTENSION GÜVENLİK DÜZELTMESİ
-- ============================================================

-- Extensions schema'yı oluştur
CREATE SCHEMA IF NOT EXISTS extensions;

-- HTTP extension'ı public'ten kaldır
DROP EXTENSION IF EXISTS http CASCADE;

-- HTTP extension'ı extensions schema'ya yükle
CREATE EXTENSION IF NOT EXISTS http
  SCHEMA extensions
  VERSION '1.6';

-- Gerekli izinleri ver
GRANT USAGE ON SCHEMA extensions TO PUBLIC;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA extensions TO PUBLIC;

SELECT '✅ HTTP extension extensions schema''ya taşındı!' as step_1_status;

-- ============================================================
-- BÖLÜM 2: RLS PERFORMANCE OPTIMIZATION
-- ============================================================

-- WHATSAPP_INCOMING_CALLS - Mevcut policy'leri kaldır
DROP POLICY IF EXISTS "Users can view their club calls" ON public.whatsapp_incoming_calls;
DROP POLICY IF EXISTS "Users can insert their club calls" ON public.whatsapp_incoming_calls;
DROP POLICY IF EXISTS "Users can update their club calls" ON public.whatsapp_incoming_calls;
DROP POLICY IF EXISTS "Users can delete their club calls" ON public.whatsapp_incoming_calls;

-- WHATSAPP_INCOMING_CALLS - Optimize edilmiş policy'ler
CREATE POLICY "Users can view their club calls"
ON public.whatsapp_incoming_calls
FOR SELECT
USING (
  club_id::text = (SELECT (current_setting('request.jwt.claims', true)::json->>'clubId'))
);

CREATE POLICY "Users can insert their club calls"
ON public.whatsapp_incoming_calls
FOR INSERT
WITH CHECK (
  club_id::text = (SELECT (current_setting('request.jwt.claims', true)::json->>'clubId'))
);

CREATE POLICY "Users can update their club calls"
ON public.whatsapp_incoming_calls
FOR UPDATE
USING (
  club_id::text = (SELECT (current_setting('request.jwt.claims', true)::json->>'clubId'))
);

CREATE POLICY "Users can delete their club calls"
ON public.whatsapp_incoming_calls
FOR DELETE
USING (
  club_id::text = (SELECT (current_setting('request.jwt.claims', true)::json->>'clubId'))
);

SELECT '✅ whatsapp_incoming_calls RLS policy''leri optimize edildi!' as step_2_status;

-- WHATSAPP_INCOMING_MESSAGES - Mevcut policy'leri kaldır
DROP POLICY IF EXISTS "Users can view their club messages" ON public.whatsapp_incoming_messages;
DROP POLICY IF EXISTS "Users can insert their club messages" ON public.whatsapp_incoming_messages;
DROP POLICY IF EXISTS "Users can update their club messages" ON public.whatsapp_incoming_messages;
DROP POLICY IF EXISTS "Users can delete their club messages" ON public.whatsapp_incoming_messages;

-- WHATSAPP_INCOMING_MESSAGES - Optimize edilmiş policy'ler
CREATE POLICY "Users can view their club messages"
ON public.whatsapp_incoming_messages
FOR SELECT
USING (
  club_id::text = (SELECT (current_setting('request.jwt.claims', true)::json->>'clubId'))
);

CREATE POLICY "Users can insert their club messages"
ON public.whatsapp_incoming_messages
FOR INSERT
WITH CHECK (
  club_id::text = (SELECT (current_setting('request.jwt.claims', true)::json->>'clubId'))
);

CREATE POLICY "Users can update their club messages"
ON public.whatsapp_incoming_messages
FOR UPDATE
USING (
  club_id::text = (SELECT (current_setting('request.jwt.claims', true)::json->>'clubId'))
);

CREATE POLICY "Users can delete their club messages"
ON public.whatsapp_incoming_messages
FOR DELETE
USING (
  club_id::text = (SELECT (current_setting('request.jwt.claims', true)::json->>'clubId'))
);

SELECT '✅ whatsapp_incoming_messages RLS policy''leri optimize edildi!' as step_3_status;

-- ============================================================
-- FİNAL RAPOR
-- ============================================================

SELECT 
  '🎉 TÜM OPTİMİZASYONLAR TAMAMLANDI!' as final_status,
  '1 extension taşındı + 8 RLS policy optimize edildi' as summary,
  'Güvenlik uyarıları ve performans sorunları çözüldü!' as result;
