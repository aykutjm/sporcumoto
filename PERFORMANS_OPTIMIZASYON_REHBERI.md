# 🚀 PERFORMANS OPTİMİZASYON REHBERİ

## 📊 MEVCUT DURUM ANALİZİ

Query istatistiklerinize göre:
- ❌ `realtime.list_changes` → %63.2 toplam zaman (36,668 çağrı)
- ✅ Diğer query'ler → Çok az sayıda çağrılıyor (sorun değil)

## 🎯 OPTİMİZASYON STRATEJİSİ

### 1. Realtime Publication'ı Azalt

**SORUN:** Çok fazla tablo realtime'da dinleniyor olabilir.

**ÇÖZÜM:**
```sql
-- Sadece gerekli tabloları realtime'da tut
ALTER PUBLICATION supabase_realtime DROP TABLE ALL;
ALTER PUBLICATION supabase_realtime ADD TABLE public.whatsapp_incoming_calls;
ALTER PUBLICATION supabase_realtime ADD TABLE public.whatsapp_incoming_messages;
ALTER PUBLICATION supabase_realtime ADD TABLE public.message_queue;
```

### 2. Index Optimizasyonu

Realtime tablolarında doğru index'ler olmalı:

```sql
-- Club ID + Created At kombinasyonu (sık kullanılıyor)
CREATE INDEX idx_whatsapp_calls_club_created 
  ON whatsapp_incoming_calls(club_id, created_at DESC);

-- Status filtreleme için
CREATE INDEX idx_whatsapp_calls_status 
  ON whatsapp_incoming_calls(status, created_at DESC);
```

### 3. Frontend'de Realtime Kullanımını Optimize Et

**JavaScript tarafında:**
```javascript
// ❌ YANLIŞ - Her satır için ayrı subscription
customers.forEach(customer => {
  supabase
    .channel(`customer-${customer.id}`)
    .on('postgres_changes', ...)
    .subscribe();
});

// ✅ DOĞRU - Tek subscription + filter
supabase
  .channel('all-customers')
  .on('postgres_changes', {
    event: '*',
    schema: 'public',
    table: 'customers',
    filter: `club_id=eq.${clubId}` // RLS zaten sağlıyor
  })
  .subscribe();
```

### 4. Realtime için Throttling/Debouncing

**Çok sık güncelleme varsa:**
```javascript
let updateTimeout;
supabase
  .channel('messages')
  .on('postgres_changes', {
    event: 'INSERT',
    schema: 'public',
    table: 'whatsapp_incoming_messages'
  }, (payload) => {
    // 500ms içinde birden fazla güncelleme gelirse birleştir
    clearTimeout(updateTimeout);
    updateTimeout = setTimeout(() => {
      handleNewMessage(payload);
    }, 500);
  })
  .subscribe();
```

## 📝 ADIM ADIM UYGULAMA

### Adım 1: Mevcut Durumu Kontrol Et
```bash
# Coolify SQL Editor'da çalıştır:
SELECT tablename 
FROM pg_publication_tables 
WHERE pubname = 'supabase_realtime';
```

### Adım 2: Gereksiz Tabloları Çıkar
```sql
-- optimize-realtime-performance.sql dosyasını çalıştır
-- (Bu dosyayı az önce oluşturdum)
```

### Adım 3: Index'leri Kontrol Et
```sql
-- Hangi index'ler var?
SELECT 
  tablename,
  indexname,
  indexdef
FROM pg_indexes
WHERE tablename IN ('whatsapp_incoming_calls', 'whatsapp_incoming_messages', 'message_queue')
ORDER BY tablename, indexname;
```

### Adım 4: Frontend Kodu Gözden Geçir
- `supabase.channel()` çağrılarını say
- Her component kendi channel açıyor mu?
- Filter'lar doğru kullanılıyor mu?

## 🔍 İZLEME

Optimizasyondan sonra tekrar kontrol et:

```sql
-- En çok zaman alan query'ler
SELECT 
  rolname,
  LEFT(query, 100) as query_start,
  calls,
  total_time,
  ROUND((total_time::numeric / SUM(total_time) OVER () * 100)::numeric, 1) || '%' as prop_time
FROM pg_stat_statements
JOIN pg_roles ON pg_stat_statements.userid = pg_roles.oid
ORDER BY total_time DESC
LIMIT 20;
```

## ⚠️ ÖNEMLİ NOTLAR

1. **Realtime Gerçekten Gerekli mi?**
   - Her tablo için realtime gerekmez
   - Sadece: gelen aramalar, gelen mesajlar, mesaj kuyruğu

2. **Frontend'de Subscription Yönetimi**
   - Component unmount olunca `.unsubscribe()` çağır
   - Memory leak önlemek için önemli

3. **RLS Zaten Filtre Ediyor**
   - Realtime'da ayrıca filter eklemeye gerek yok
   - `club_id` zaten RLS ile filtreleniyor

## 🎯 BEKLENTİ

Bu optimizasyonlardan sonra:
- `realtime.list_changes` %63 → %10-20'ye düşmeli
- Sayfa yükleme hızı artmalı
- Gereksiz network trafiği azalmalı

## 📌 SONRAKİ ADIMLAR

1. ✅ `optimize-realtime-performance.sql` dosyasını Coolify'da çalıştır
2. ✅ Frontend kodunu gözden geçir (channel subscription'ları)
3. ✅ 1 gün sonra tekrar `pg_stat_statements` kontrol et
4. ✅ Gerekirse daha fazla fine-tuning yap
