# ⚡ HIZLI KURULUM - 5 DAKİKADA BİTİR!

Web tarayıcınızda Supabase Dashboard ile yapacaksınız. CLI kurulumuna gerek yok!

---

## 🎯 ADIM 1: VERITABANI TABLOSUNU OLUŞTUR (2 dakika)

### 1.1 Supabase Dashboard'u Açın
- https://supabase.com/dashboard
- Projenizi seçin

### 1.2 SQL Editor'ü Açın
- Sol menüden **SQL Editor** tıklayın
- **New query** tıklayın

### 1.3 Kodu Yapıştırın
Şu dosyayı açın ve **TÜMÜNÜ** kopyalayıp SQL Editor'e yapıştırın:

📁 **Dosya:** `create-autoReplySent-table.sql`

### 1.4 Çalıştırın
- **Run** butonuna tıklayın (veya Ctrl+Enter)
- Success mesajını görmelisiniz ✅

---

## 🎯 ADIM 2: EDGE FUNCTION OLUŞTUR (3 dakika)

### 2.1 Edge Functions Sayfasını Açın
- Sol menüden **Edge Functions** tıklayın
- **Create a new function** butonuna tıklayın

### 2.2 Function İsmini Girin
- Function name: `auto-reply-missed-calls`
- **Create function** tıklayın

### 2.3 Kodu Yapıştırın
Editor açılacak. Oradaki varsayılan kodu **SİLİN** ve yerine şunu yapıştırın:

📁 **Dosya:** `supabase\functions\auto-reply-missed-calls\index.ts`

**ÖNEMLİ:** Dosyayı bir metin editörü ile açın (VS Code, Notepad++) ve **TÜMÜNÜ** kopyalayın!

### 2.4 Deploy Edin
- **Deploy** butonuna tıklayın
- Deployment tamamlanana kadar bekleyin (30-60 saniye)
- Success mesajını görmelisiniz ✅

---

## 🎯 ADIM 3: CRON JOB KUR (2 dakika)

### 3.1 pg_cron Extension'ı Enable Edin
- Sol menüden **Database > Extensions** tıklayın
- Arama kutusuna `pg_cron` yazın
- **Enable** butonuna tıklayın

### 3.2 SQL Editor'e Geri Dönün
- Sol menüden **SQL Editor** tıklayın
- **New query** tıklayın

### 3.3 Cron Job Kodunu Yapıştırın

```sql
-- Her 2 dakikada bir otomatik çalıştır
SELECT cron.schedule(
  'auto-reply-missed-calls',
  '*/2 * * * *',
  $$
  SELECT
    net.http_post(
      url:='https://YOUR_PROJECT_ID.supabase.co/functions/v1/auto-reply-missed-calls',
      headers:='{"Content-Type": "application/json", "Authorization": "Bearer YOUR_ANON_KEY"}'::jsonb,
      body:='{}'::jsonb
    ) as request_id;
  $$
);
```

### 3.4 Değerleri Değiştirin

**YOUR_PROJECT_ID** değiştirin:
1. Sol menüden **Settings > General** tıklayın
2. **Reference ID** kopyalayın (örn: `abcdefgh1234567`)
3. SQL'de `YOUR_PROJECT_ID` yerine yapıştırın

**YOUR_ANON_KEY** değiştirin:
1. Sol menüden **Settings > API** tıklayın
2. **anon public** key'i kopyalayın (uzun bir token, `eyJ...` ile başlar)
3. SQL'de `YOUR_ANON_KEY` yerine yapıştırın

### 3.5 Çalıştırın
- **Run** butonuna tıklayın
- Success mesajını görmelisiniz ✅

---

## ✅ TEST ET (1 dakika)

### Test 1: Edge Function Manuel Test
1. Sol menüden **Edge Functions** tıklayın
2. `auto-reply-missed-calls` fonksiyonunu seçin
3. **Invoke Function** butonuna tıklayın
4. Response böyle olmalı:

```json
{
  "success": true,
  "totalMessagesSent": 0,
  "timestamp": "2025-11-20T..."
}
```

### Test 2: Cron Job Kontrol
SQL Editor'de çalıştırın:

```sql
SELECT * FROM cron.job WHERE jobname = 'auto-reply-missed-calls';
```

Bir satır görmeli ve `active = true` olmalı ✅

---

## 🎉 TAMAMDIR!

Artık sistem:
- ✅ Her 2 dakikada otomatik çalışıyor
- ✅ Sayfa kapalı olsa bile mesaj gönderiyor
- ✅ Mesai saatleri kontrolü yapıyor
- ✅ Eşleşen WhatsApp cihazından gönderiyor

---

## 🔍 SORUN GİDERME

### "Edge Function hata veriyor"

**Logs kontrol edin:**
1. Edge Functions > `auto-reply-missed-calls` seçin
2. **Logs** sekmesine tıklayın
3. Hataları görün

**En yaygın hatalar:**
- ❌ `clubs` tablosunda `settings` kolonu yok → Ekleyin
- ❌ `whatsappDevices` tablosu yok → Oluşturun
- ❌ Bulutfon API Key eksik → `clubs.settings.bulutfonApiKey` ekleyin

### "Cron job çalışmıyor"

```sql
-- Job geçmişini kontrol et
SELECT * FROM cron.job_run_details 
WHERE jobid = (SELECT jobid FROM cron.job WHERE jobname = 'auto-reply-missed-calls')
ORDER BY start_time DESC 
LIMIT 10;
```

Hata varsa `return_message` kolonunda görürsünüz.

### "Hiç mesaj gönderilmiyor"

Kontrol listesi:
1. `clubs` tablosunda `settings.bulutfonApiKey` var mı?
2. `whatsappDevices` tablosunda aktif cihaz var mı?
3. Bulutfon'da cevapsız çağrı var mı? (son 10 dakika)
4. Çalışma saatleri aktif mi ve doğru ayarlı mı?

```sql
-- Kontrol sorguları
SELECT id, settings->'bulutfonApiKey' FROM clubs;
SELECT * FROM whatsappDevices WHERE status = 'active';
SELECT * FROM autoReplySent ORDER BY createdAt DESC LIMIT 10;
```

---

## 📞 YARDIM

Hala sorun mu var?

1. Edge Function Logs kontrol edin
2. Cron job geçmişini kontrol edin
3. Veritabanı tablolarını kontrol edin

**Log dosyaları:**
- Edge Functions > Logs
- SQL: `SELECT * FROM cron.job_run_details ORDER BY start_time DESC;`
