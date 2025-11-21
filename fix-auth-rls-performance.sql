-- RLS Policy Performance Optimization
-- auth.<function>() çağrılarını (select auth.<function>()) ile değiştir
-- Bu, her satır için yeniden değerlendirmeyi önler ve performansı artırır

-- ============================================================
-- WHATSAPP_INCOMING_CALLS TABLOSU İÇİN RLS POLİCY GÜNCELLEMELERİ
-- ============================================================

-- Önce mevcut policy'leri kaldır
DROP POLICY IF EXISTS "Users can view their club calls" ON public.whatsapp_incoming_calls;
DROP POLICY IF EXISTS "Users can insert their club calls" ON public.whatsapp_incoming_calls;
DROP POLICY IF EXISTS "Users can update their club calls" ON public.whatsapp_incoming_calls;
DROP POLICY IF EXISTS "Users can delete their club calls" ON public.whatsapp_incoming_calls;

-- Optimize edilmiş policy'leri oluştur (SELECT ile)
CREATE POLICY "Users can view their club calls"
ON public.whatsapp_incoming_calls
FOR SELECT
USING (
  club_id::text = (SELECT (auth.jwt()->>'clubId'))
);

CREATE POLICY "Users can insert their club calls"
ON public.whatsapp_incoming_calls
FOR INSERT
WITH CHECK (
  club_id::text = (SELECT (auth.jwt()->>'clubId'))
);

CREATE POLICY "Users can update their club calls"
ON public.whatsapp_incoming_calls
FOR UPDATE
USING (
  club_id::text = (SELECT (auth.jwt()->>'clubId'))
);

CREATE POLICY "Users can delete their club calls"
ON public.whatsapp_incoming_calls
FOR DELETE
USING (
  club_id::text = (SELECT (auth.jwt()->>'clubId'))
);

-- ============================================================
-- WHATSAPP_INCOMING_MESSAGES TABLOSU İÇİN RLS POLİCY GÜNCELLEMELERİ
-- ============================================================

-- Önce mevcut policy'leri kaldır
DROP POLICY IF EXISTS "Users can view their club messages" ON public.whatsapp_incoming_messages;
DROP POLICY IF EXISTS "Users can insert their club messages" ON public.whatsapp_incoming_messages;
DROP POLICY IF EXISTS "Users can update their club messages" ON public.whatsapp_incoming_messages;
DROP POLICY IF EXISTS "Users can delete their club messages" ON public.whatsapp_incoming_messages;

-- Optimize edilmiş policy'leri oluştur (SELECT ile)
-- WHATSAPP_INCOMING_MESSAGES - Mevcut policy'leri kaldır
DROP POLICY IF EXISTS "Users can view their club messages" ON public.whatsapp_incoming_messages;
DROP POLICY IF EXISTS "Users can insert their club messages" ON public.whatsapp_incoming_messages;
DROP POLICY IF EXISTS "Users can update their club messages" ON public.whatsapp_incoming_messages;
DROP POLICY IF EXISTS "Users can delete their club messages" ON public.whatsapp_incoming_messages;

-- Optimize edilmiş policy'leri oluştur (SELECT ile)
CREATE POLICY "Users can view their club messages"
ON public.whatsapp_incoming_messages
FOR SELECT
USING (
  club_id::text = (SELECT (auth.jwt()->>'clubId'))
);

CREATE POLICY "Users can insert their club messages"
ON public.whatsapp_incoming_messages
FOR INSERT
WITH CHECK (
  club_id::text = (SELECT (auth.jwt()->>'clubId'))
);

CREATE POLICY "Users can update their club messages"
ON public.whatsapp_incoming_messages
FOR UPDATE
USING (
  club_id::text = (SELECT (auth.jwt()->>'clubId'))
);

CREATE POLICY "Users can delete their club messages"
ON public.whatsapp_incoming_messages
FOR DELETE
USING (
  club_id::text = (SELECT (auth.jwt()->>'clubId'))
);

-- ============================================================
-- İŞLEM TAMAMLANDI
-- ============================================================

SELECT 
  '✅ Tüm RLS policy''ler optimize edildi!' as status,
  '8 policy güncellendi (4 whatsapp_incoming_calls + 4 whatsapp_incoming_messages)' as details,
  'auth.jwt() → (SELECT auth.jwt()) değişikliği yapıldı' as optimization,
  'Performans artışı: Her satır için tekrar değerlendirme YOK!' as benefit;
