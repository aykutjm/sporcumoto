# 🚀 SUPABASE EDGE FUNCTION KURULUM KILAVUZU
## WhatsApp Mesaj Kuyruğu - 7/24 Otomatik Gönderim

---

## 📋 İÇİNDEKİLER
1. [Ne Yapar?](#ne-yapar)
2. [Gereksinimler](#gereksinimler)
3. [Kurulum Adımları](#kurulum-adımları)
4. [Test](#test)
5. [Otomatik Çalıştırma](#otomatik-çalıştırma)
6. [İzleme ve Sorun Giderme](#izleme-ve-sorun-giderme)

---

## 🎯 NE YAPAR?

**Problem:**
- ❌ Web sitesi kapalı olunca bekleyen WhatsApp mesajları gönderilmiyor
- ❌ Admin paneli açık değilse kuyruk durur

**Çözüm:**
- ✅ **Supabase Edge Function** = 7/24 çalışan backend
- ✅ Web sitesi kapalı olsa bile mesajları gönderir
- ✅ Her 1 dakikada bekleyen mesajları kontrol eder
- ✅ Maksimum 10 mesaj/dakika gönderir

---

## 📦 GEREKSİNİMLER

### 1. Supabase CLI (Bilgisayarına Kur)
```powershell
# Windows (Scoop ile)
scoop install supabase

# Veya manuel indirme:
# https://github.com/supabase/cli/releases
```

### 2. Evolution API Bilgileri
- Evolution API URL
- Evolution API Key
- (Admin panelde zaten kullanıyorsun)

---

## 🛠️ KURULUM ADIMLARI

### ADIM 1: Supabase CLI Giriş Yap

```powershell
# Terminal aç
cd C:\Users\adnan\Desktop\Projeler\sporcum-supabase

# Supabase'e giriş yap
supabase login
```

Tarayıcıda açılacak, **Allow Access** butonuna tıkla.

---

### ADIM 2: Supabase Projesini Linkinle

```powershell
# Proje ID'ni bul (Dashboard → Settings → General → Reference ID)
# Örnek: abcdefghijklmnopqrst

supabase link --project-ref YOUR_PROJECT_ID
```

**Not:** Project ID'yi Supabase Dashboard'dan alabilirsin.

---

### ADIM 3: Edge Function'ı Deploy Et

```powershell
# Function'ı yükle
supabase functions deploy process-whatsapp-queue

# Başarılı olursa şöyle bir çıktı göreceksin:
# ✅ Deployed Function process-whatsapp-queue on project YOUR_PROJECT
# URL: https://YOUR_PROJECT.supabase.co/functions/v1/process-whatsapp-queue
```

---

### ADIM 4: Environment Variables Ekle

**Supabase Dashboard'a git:**
1. **Edge Functions** → **process-whatsapp-queue** → **Settings** sekmesi
2. **Secrets** bölümüne şunları ekle:

```
EVOLUTION_API_URL = https://evolution-api.sporcum.app
EVOLUTION_API_KEY = (Evolution API key buraya)
```

**VEYA** Terminal ile ekle:
```powershell
supabase secrets set EVOLUTION_API_URL=https://evolution-api.sporcum.app
supabase secrets set EVOLUTION_API_KEY=YOUR_EVOLUTION_KEY
```

---

### ADIM 5: Test Et (Manual)

```powershell
# Terminal'den test et
supabase functions invoke process-whatsapp-queue
```

**VEYA** Postman/Insomnia ile:
```
POST https://YOUR_PROJECT.supabase.co/functions/v1/process-whatsapp-queue
Headers:
  Authorization: Bearer YOUR_ANON_KEY
```

**Başarılı yanıt:**
```json
{
  "success": true,
  "processed": 2,
  "failed": 0,
  "total": 2,
  "timestamp": "2025-11-15T10:30:00.000Z"
}
```

---

## ⏰ OTOMATIK ÇALIŞTIRMA

Edge Function hazır ama otomatik çalışması için **dışarıdan tetiklenmeli**.

### SEÇENEK 1: Cron-Job.org (ÖNERİLİR - ÜCRETSİZ)

1. **https://cron-job.org** sitesine git
2. **Sign Up** → Ücretsiz hesap aç
3. **Create Cronjob** butonuna tıkla

**Ayarlar:**
- **Title:** WhatsApp Mesaj Kuyruğu
- **URL:** `https://YOUR_PROJECT.supabase.co/functions/v1/process-whatsapp-queue`
- **Schedule:** `*/1 * * * *` (her dakika)
- **Request Method:** POST
- **Headers:**
  - Key: `Authorization`
  - Value: `Bearer YOUR_ANON_KEY`

4. **Create** butonuna tıkla
5. **✅ Tamam!** Artık her dakika otomatik çalışacak

---

### SEÇENEK 2: EasyCron (Alternatif)

1. **https://www.easycron.com** → Sign Up
2. **Add Cron Job**
3. URL ve header ayarlarını yap (yukarıdaki gibi)
4. Schedule: `Every minute`

---

### SEÇENEK 3: Supabase Pro Plan (Ücretli)

Eğer **Supabase Pro** plan varsa `pg_cron` kullanabilirsin:

```sql
-- Supabase Dashboard → SQL Editor

SELECT cron.schedule(
    'process-whatsapp-queue',
    '* * * * *', -- Her dakika
    $$
    SELECT 
      net.http_post(
        url := 'https://YOUR_PROJECT.supabase.co/functions/v1/process-whatsapp-queue',
        headers := '{"Authorization": "Bearer YOUR_SERVICE_ROLE_KEY"}'::jsonb
      )
    $$
);
```

---

## 🧪 TEST

### 1. Manuel Test Mesajı Ekle

```sql
-- Supabase Dashboard → SQL Editor

INSERT INTO public."messageQueue" (
    id,
    "clubId",
    phone,
    message,
    "deviceId",
    "recipientName",
    status,
    "scheduledFor",
    "createdAt",
    "updatedAt"
) VALUES (
    'test_' || gen_random_uuid()::text,
    'YOUR_CLUB_ID',
    '05449367543', -- Test telefon
    'Bu bir test mesajıdır. Sistem 7/24 çalışıyor! 🚀',
    'YOUR_DEVICE_ID', -- WhatsApp instance name
    'Test Kullanıcı',
    'pending',
    NOW(), -- Hemen gönder
    NOW(),
    NOW()
);
```

### 2. Edge Function'ı Çalıştır

```powershell
supabase functions invoke process-whatsapp-queue
```

### 3. Sonucu Kontrol Et

```sql
-- Gönderilen mesajlar
SELECT * FROM "messageQueue" WHERE status = 'sent' ORDER BY "sentAt" DESC LIMIT 5;

-- Başarısız mesajlar
SELECT * FROM "messageQueue" WHERE status = 'failed' ORDER BY "failedAt" DESC LIMIT 5;
```

---

## 📊 İZLEME VE SORUN GİDERME

### Log'ları Görüntüle

**Supabase Dashboard:**
1. **Edge Functions** → **process-whatsapp-queue**
2. **Logs** sekmesi
3. Real-time log akışını izle

**Veya Terminal:**
```powershell
supabase functions serve process-whatsapp-queue
```

---

### Sık Karşılaşılan Sorunlar

#### ❌ "Evolution API credentials eksik"
**Çözüm:** Environment variables eklenmiş mi kontrol et
```powershell
supabase secrets list
```

#### ❌ "Database error: permission denied"
**Çözüm:** Service Role Key kullanıldığından emin ol
- Dashboard → Settings → API → `service_role` key

#### ❌ "API error: 401"
**Çözüm:** Evolution API Key doğru mu kontrol et
- Admin panelde çalışıyorsa aynı key'i kullan

#### ❌ Mesajlar gitmiyor
**Çözüm:** 
1. WhatsApp cihazı bağlı mı kontrol et
2. Evolution API erişilebilir mi test et
3. Log'ları incele (yukarıda)

---

## 🎯 SONRAKİ ADIMLAR

### ✅ Şu Anda Çalışanlar:
- Edge Function hazır ve çalışıyor
- Manual tetikleme yapılabiliyor
- Bekleyen mesajları tespit ediyor

### ⏰ Otomatik Çalışma İçin:
- **Cron-Job.org** ayarı yap (5 dakika)
- VEYA **EasyCron** kullan
- VEYA **Supabase Pro** al (pg_cron)

### 📈 İyileştirmeler (Opsiyonel):
- Retry mekanizması (başarısız mesajları tekrar dene)
- Günlük rapor (kaç mesaj gönderildi)
- Webhook (mesaj gönderilince bildirim)

---

## 🆘 YARDIM

**Sorun mu var?**
1. Log'ları kontrol et (Dashboard → Edge Functions → Logs)
2. Test mesajı ekle (yukarıdaki SQL)
3. Manuel çalıştır (`supabase functions invoke`)
4. Hata mesajını bana gönder

**Başarılı Kurulum:**
```json
{
  "success": true,
  "processed": 5,
  "failed": 0,
  "total": 5
}
```

Bu yanıtı alıyorsan **HER ŞEY TAMAM!** 🎉

---

## 📞 İLETİŞİM

Sorularını ya da hataları buraya yaz, hemen yardım ederim! 🚀
