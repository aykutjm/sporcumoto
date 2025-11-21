# 🚀 Cevapsız Çağrı Otomatik Mesaj Sistemi - Hızlı Başlangıç

## ✅ TAMAMLANAN GÜNCELLEMELER

### 1. Frontend (admin.html)
- ✅ Mesai saatleri artık **Ayarlar > Mesaj Gönderim Çalışma Saatleri**'nden alınıyor
- ✅ Çalışma günleri kontrolü eklendi (Pazartesi-Cuma vs)
- ✅ Dakika seviyesinde hassas saat kontrolü
- ✅ Her 2 dakikada bir otomatik kontrol
- ✅ Sayfa açıkken çalışıyor ✅

### 2. Backend (Supabase Edge Function)
- ✅ Edge Function oluşturuldu: `auto-reply-missed-calls`
- ✅ Sayfa kapalıyken de çalışır
- ✅ Multi-kulüp desteği
- ✅ Çalışma saatleri kontrolü
- ✅ Device matching logic
- ✅ Duplicate kontrolü

---

## 📋 KURULUM ADIMLARI

### ADIM 1: Veritabanı Tablosu Oluştur

Supabase Dashboard > SQL Editor'de çalıştırın:

```sql
-- Dosya: create-autoReplySent-table.sql
-- İçeriği kopyalayıp SQL Editor'de çalıştırın
```

✅ **Tablo oluşturuldu mu?** Devam edin.

---

### ADIM 2: Edge Function Kurulumu

**PowerShell'de çalıştırın:**

```powershell
cd c:\Users\adnan\Desktop\Projeler\sporcum-supabase
.\setup-edge-function.ps1
```

Script size şunları soracak:
1. Project ID (Dashboard > Settings > General)
2. Veritabanı tablosu oluşturuldu mu?

✅ **Tamamlandı mı?** Devam edin.

---

### ADIM 3: Cron Job Kurulumu (OTOMATİK ÇALIŞTIRMA)

1. **Supabase Dashboard > Database > Extensions**
   - `pg_cron` extension'ı enable edin

2. **SQL Editor'de şu komutu çalıştırın:**

```sql
-- Her 2 dakikada bir otomatik çalıştır
SELECT cron.schedule(
  'auto-reply-missed-calls',
  '*/2 * * * *', -- Her 2 dakika
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

**ÖNEMLİ:** Değiştirin:
- `YOUR_PROJECT_ID` → Project Settings > General > Reference ID
- `YOUR_ANON_KEY` → Project Settings > API > anon public key

✅ **Cron job kuruldu!**

---

## 🧪 TEST

### Manuel Test (Edge Function)

```powershell
# Supabase Functions çalıştır
supabase functions serve auto-reply-missed-calls
```

Başka terminal:

```powershell
curl -X POST "http://localhost:54321/functions/v1/auto-reply-missed-calls" `
  -H "Authorization: Bearer YOUR_ANON_KEY" `
  -H "Content-Type: application/json"
```

### Frontend Test (Browser)

1. Sayfayı yenileyin (Ctrl+F5)
2. Console'u açın
3. Debug script'i çalıştırın:

```javascript
// debug-missed-calls.js içeriğini console'a yapıştırın
```

4. Manuel test:

```javascript
await window.sendAutoReplyToNewMissedCalls()
```

**Beklenen log:**

```
🚀 sendAutoReplyToNewMissedCalls() başlatıldı
✅ 2 WhatsApp cihazı bulundu
📞 3 cevapsız çağrı bulundu
⏰ Çağrı çalışma saati dışında yapılmış (22:00), otomatik mesaj gönderilmiyor
✅ Çağrı çalışma saati içinde (14:30), otomatik mesaj gönderiliyor...
✅ Eşleşen cihaz bulundu: Kulup (0362 363 00 64)
✅ Otomatik mesaj kuyruğa eklendi: 05515046792 (Cihaz: Kulup)
```

---

## 🔍 LOG KONTROL

### Edge Function Logları

```powershell
supabase functions logs auto-reply-missed-calls --tail
```

### Cron Job Kontrol

```sql
-- Çalışan cron job'ları listele
SELECT * FROM cron.job;

-- Cron job geçmişi
SELECT * FROM cron.job_run_details 
WHERE jobid = (SELECT jobid FROM cron.job WHERE jobname = 'auto-reply-missed-calls')
ORDER BY start_time DESC
LIMIT 10;
```

---

## ⚙️ AYARLAR (Admin Panel)

**Ayarlar > WhatsApp Ayarları > Mesaj Gönderim Çalışma Saatleri**

- ☑️ Çalışma Saatleri Aktif
- 🕐 Başlangıç: 09:00
- 🕐 Bitiş: 18:00
- 📅 Çalışma Günleri: Pazartesi-Cuma ✅

**Önemli:** Bu ayarlar hem frontend hem de edge function tarafından kullanılır!

---

## 📊 İSTATİSTİKLER

Supabase Dashboard > SQL Editor:

```sql
-- Bugün gönderilen otomatik mesajlar
SELECT * FROM auto_reply_stats
WHERE date = CURRENT_DATE;

-- Son 7 gün özeti
SELECT 
  date,
  SUM(total_sent) as total_messages,
  SUM(unique_phones) as unique_numbers
FROM auto_reply_stats
WHERE date >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY date
ORDER BY date DESC;
```

---

## ❓ SORUN GİDERME

### "Mesaj gönderilmiyor"

1. **Çalışma saati kontrolü:**
   ```javascript
   console.log(clubSettings.workingHoursEnabled); // true olmalı
   console.log(clubSettings.workingHoursStart);   // "09:00"
   console.log(clubSettings.workingHoursEnd);     // "18:00"
   ```

2. **WhatsApp cihazları:**
   ```javascript
   console.log(whatsappDevices); // Array olmalı, boş olmamalı
   ```

3. **Cevapsız çağrılar:**
   ```javascript
   console.log(window.incomingCallsCategories.unanswered);
   ```

### "Edge function çalışmıyor"

```powershell
# Log kontrol
supabase functions logs auto-reply-missed-calls --tail

# Yeniden deploy
supabase functions deploy auto-reply-missed-calls
```

### "Cron job çalışmıyor"

```sql
-- Job'ı sil
SELECT cron.unschedule('auto-reply-missed-calls');

-- Yeniden oluştur (yukarıdaki SQL'i tekrar çalıştır)
```

---

## 🎯 ÖZELLİKLER

✅ **Otomatik çalışır** - Sayfa açık olsun olmasın  
✅ **Mesai saati kontrolü** - Ayarlardan yönetilebilir  
✅ **Akıllı cihaz seçimi** - Aranan numaraya göre eşleştirir  
✅ **Günlük limit** - Aynı kişiye günde 1 mesaj  
✅ **CRM şablon** - Özelleştirilebilir mesaj  
✅ **Multi-kulüp** - Tüm kulüpler için çalışır  

---

## 📞 İLETİŞİM

Sorun mu var? Log'ları kontrol edin:
- Frontend: Browser Console
- Backend: `supabase functions logs`
- Database: `SELECT * FROM autoReplySent ORDER BY createdAt DESC LIMIT 10;`
