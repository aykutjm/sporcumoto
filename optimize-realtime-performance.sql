-- ============================================================
-- REALTIME PERFORMANS OPTİMİZASYONU - SADECE INDEX'LER
-- ============================================================
-- realtime.list_changes query'si toplam zamanın %63'ünü alıyor
-- Bu script sadece index optimizasyonu yapar
-- Publication değişikliği yapmaz (riskli)
-- ============================================================

-- 1. Realtime için hangi tablolar dinleniyor kontrol et
SELECT 
  schemaname,
  tablename,
  COUNT(*) as publication_count
FROM pg_publication_tables
WHERE pubname = 'supabase_realtime'
GROUP BY schemaname, tablename
ORDER BY tablename;

-- NOT: Publication'dan tablo çıkarmak riskli olabilir
-- Önce yukarıdaki sorgu ile hangi tabloların realtime'da olduğunu görün
-- Eğer gerçekten çok fazla tablo varsa, manuel olarak gereksiz olanları çıkarın:
-- Örnek: ALTER PUBLICATION supabase_realtime DROP TABLE public.tablo_adi;

-- NOT: Publication'dan tablo çıkarmak riskli olabilir
-- Önce yukarıdaki sorgu ile hangi tabloların realtime'da olduğunu görün
-- Eğer gerçekten çok fazla tablo varsa, manuel olarak gereksiz olanları çıkarın:
-- Örnek: ALTER PUBLICATION supabase_realtime DROP TABLE public.tablo_adi;

-- 2. SADECE INDEX OPTİMİZASYONU (GÜVENLİ)
-- Bu tablolarda primary key ve sık kullanılan kolonlara index olmalı

-- whatsapp_incoming_calls için
CREATE INDEX IF NOT EXISTS idx_whatsapp_calls_club_created 
  ON public.whatsapp_incoming_calls(club_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_whatsapp_calls_status 
  ON public.whatsapp_incoming_calls(status, created_at DESC);

-- whatsapp_incoming_messages için  
CREATE INDEX IF NOT EXISTS idx_whatsapp_messages_club_created 
  ON public.whatsapp_incoming_messages(club_id, created_at DESC);

-- message_queue için
CREATE INDEX IF NOT EXISTS idx_message_queue_status 
  ON public.message_queue(status, scheduled_at);

-- 3. Eski realtime slot'ları kontrol et
-- Kullanılmayan replication slot'lar performansı düşürür
SELECT 
  slot_name, 
  active, 
  pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn)) as lag
FROM pg_replication_slots
WHERE slot_name LIKE 'supabase_realtime%';

SELECT '✅ Index optimizasyonu tamamlandı!' as status;
SELECT 'ℹ️  Yukarıdaki tablolara bakın - çok fazla tablo varsa frontend kodunu optimize edin' as info;
