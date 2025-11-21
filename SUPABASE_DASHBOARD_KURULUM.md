# 🎯 SUPABASE DASHBOARD KURULUM (CLI OLMADAN)
## WhatsApp Mesaj Kuyruğu - 7/24 Otomatik Sistem

---

## ⚡ HIZLI BAŞLANGIÇ

**3 basit adım:**
1. Edge Function oluştur (Dashboard'dan)
2. Otomatik çalıştırma SQL'i çalıştır
3. Test et!

**Toplam süre:** ~10 dakika

---

## 📋 ADIM 1: EDGE FUNCTION OLUŞTUR

### 1.1 Supabase Dashboard'a Git
- https://supabase.com/dashboard → Projen
- Sol menüden **Edge Functions** tıkla
- **Create a new function** butonuna tıkla

### 1.2 Function Bilgilerini Gir
- **Function name:** `process-whatsapp-queue`
- **Region:** Closest to your users (Europe West için Frankfurt seç)

### 1.3 Kodu Yapıştır
**`supabase/functions/process-whatsapp-queue/index.ts`** dosyasını aç, **TAMAMINI KOPYALA** ve yapıştır.

```typescript
// Dosya içeriği çok uzun, dosyadan kopyala!
// supabase/functions/process-whatsapp-queue/index.ts
```

### 1.4 Environment Variables Ekle
**Settings** sekmesine geç, şunları ekle:

| Key | Value | Açıklama |
|-----|-------|----------|
| `SUPABASE_URL` | (otomatik dolu) | Proje URL'i |
| `SUPABASE_SERVICE_ROLE_KEY` | (Settings → API'den al) | Service Role Key |
| `EVOLUTION_API_URL` | `https://evolution-api.sporcum.app` | Evolution API adresi |
| `EVOLUTION_API_KEY` | `YOUR_EVOLUTION_KEY` | Admin panelde kullandığın key |

**Service Role Key nerede?**
- Dashboard → **Settings** → **API** → **Project API keys** → `service_role` (gizli olan)

### 1.5 Deploy Et
- **Deploy function** butonuna tıkla
- 30-60 saniye bekle
- ✅ "Successfully deployed" yazısını gör

---

## 📋 ADIM 2: OTOMATIK ÇALIŞTIRMA AYARLA

Edge Function hazır ama otomatik çalışması için 2 yöntem var:

### YÖNTEM A: SQL ile PostgreSQL Fonksiyonu (ÖNERİLİR)

**Supabase Dashboard → SQL Editor → New query**

```sql
-- PostgreSQL fonksiyonu oluştur
CREATE OR REPLACE FUNCTION public.process_whatsapp_queue()
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    result_json json;
    function_url text;
    service_key text;
BEGIN
    -- Supabase Edge Function URL'i (kendi project ID'ni yaz)
    function_url := 'https://YOUR_PROJECT_ID.supabase.co/functions/v1/process-whatsapp-queue';
    
    -- Service Role Key (Settings → API'den aldığın)
    service_key := 'YOUR_SERVICE_ROLE_KEY';
    
    -- Edge Function'ı çağır
    SELECT content::json INTO result_json
    FROM http((
        'POST',
        function_url,
        ARRAY[http_header('Authorization', 'Bearer ' || service_key)],
        'application/json',
        ''
    )::http_request);
    
    RETURN result_json;
END;
$$;
```

**ÖNEMLİ:** 
- `YOUR_PROJECT_ID` → Dashboard URL'indeki project ID
- `YOUR_SERVICE_ROLE_KEY` → Settings → API'den aldığın service_role key

**SQL'i çalıştır** → ✅ Success yazmalı

---

### YÖNTEM B: Cron-Job.org (Harici Servis - ÜCRETSİZ)

**Eğer SQL çalışmazsa bunu kullan:**

1. **https://cron-job.org** → Sign Up (ücretsiz)
2. **Create Cronjob** tıkla
3. Ayarları yap:

```
Title: WhatsApp Mesaj Kuyruğu
URL: https://YOUR_PROJECT_ID.supabase.co/functions/v1/process-whatsapp-queue
Schedule: */1 * * * * (her dakika)
Request Method: POST
Headers:
  Authorization: Bearer YOUR_ANON_KEY
```

**ANON_KEY nerede?**
- Dashboard → **Settings** → **API** → `anon` key (public olan)

4. **Create** butonuna tıkla → ✅ Tamam!

---

## 📋 ADIM 3: TEST ET

### 3.1 Test Mesajı Ekle

**Supabase Dashboard → SQL Editor**

```sql
-- Test mesajı ekle
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
    'atakumtenis', -- Kendi club ID'n
    '05449367543', -- Test telefon numarası
    'WhatsApp mesaj kuyruğu çalışıyor! 🚀 Sistem 7/24 aktif.',
    'atakumtenis', -- WhatsApp instance name
    'Test Kullanıcı',
    'pending',
    NOW(), -- Hemen gönder
    NOW(),
    NOW()
);
```

### 3.2 Manuel Çalıştır (İlk Test)

**Edge Functions → process-whatsapp-queue → Invoke**

Veya **SQL Editor:**
```sql
-- PostgreSQL fonksiyonu oluşturduysanız
SELECT process_whatsapp_queue();
```

### 3.3 Sonucu Kontrol Et

```sql
-- Gönderilen mesajlar
SELECT * FROM "messageQueue" 
WHERE status = 'sent' 
ORDER BY "sentAt" DESC 
LIMIT 5;

-- Başarısız mesajlar (varsa)
SELECT * FROM "messageQueue" 
WHERE status = 'failed' 
ORDER BY "failedAt" DESC 
LIMIT 5;
```

**Başarılı ise:**
- `status = 'sent'`
- `sentAt` dolu
- Telefona mesaj gelmiş olmalı ✅

---

## 📊 İZLEME

### Log'ları Görüntüle

**Edge Functions → process-whatsapp-queue → Logs**

Real-time log akışını göreceksin:
```
INFO Başlatıldı: 2025-11-15 10:30:00
INFO Bekleyen mesaj sayısı: 3
INFO Mesaj gönderildi: 05449367543
INFO Mesaj gönderildi: 05321234567
INFO İşlem tamamlandı: 3 başarılı, 0 hatalı
```

---

## 🎯 OTOMATIK ÇALIŞTIRMA DOĞRULAMA

### SQL Fonksiyonu Test Et
```sql
-- Şu an çalıştır
SELECT process_whatsapp_queue();

-- Sonuç şöyle olmalı:
{
  "success": true,
  "processed": 2,
  "failed": 0,
  "total": 2
}
```

### Cron-Job.org Test Et
- Dashboard'a git
- Cronjob'ın yanında **▶ Run now** butonuna tıkla
- **Execution History** sekmesinde sonucu gör
- ✅ Status: 200 OK olmalı

---

## 🛠️ SORUN GİDERME

### ❌ "Evolution API credentials eksik"
**Çözüm:**
1. Edge Functions → process-whatsapp-queue → Settings
2. Environment Variables kontrol et
3. `EVOLUTION_API_URL` ve `EVOLUTION_API_KEY` var mı?

### ❌ "Database error: permission denied"
**Çözüm:**
1. Settings → API → `service_role` key'i al
2. Environment Variables'a `SUPABASE_SERVICE_ROLE_KEY` ekle

### ❌ "HTTP error 401"
**Çözüm:**
1. Evolution API Key doğru mu kontrol et
2. Admin panelde çalışan key'i kullan

### ❌ Mesajlar gitmiyor
**Kontrol et:**
```sql
-- WhatsApp cihazı bağlı mı?
SELECT * FROM "branches" WHERE id = 'atakumtenis';

-- Kuyrukta mesaj var mı?
SELECT * FROM "messageQueue" WHERE status = 'pending';

-- Log'larda hata var mı?
-- Edge Functions → Logs sekmesi
```

---

## ✅ BAŞARILI KURULUM KONTROLLERİ

- [ ] Edge Function oluşturuldu
- [ ] Environment variables eklendi
- [ ] Function deploy edildi
- [ ] Test mesajı eklendi
- [ ] Manuel çalıştırma başarılı
- [ ] Telefona mesaj geldi
- [ ] Otomatik çalıştırma ayarlandı (SQL veya Cron)
- [ ] Log'lar düzgün görünüyor

**Hepsi ✅ ise SİSTEM HAZIR!** 🎉

---

## 📱 KULLANIM

**Artık sistem 7/24 çalışıyor!**

1. Admin panelde WhatsApp mesajı gönder
2. Çalışma saatleri dışındaysa → Kuyruğa eklenir
3. Her 1 dakikada kuyruk kontrol edilir
4. Zamanı gelmiş mesajlar otomatik gönderilir
5. Web sitesi kapalı olsa bile çalışır! ✅

---

## 🆘 YARDIM

**Sorun mu var?**
1. Edge Functions → Logs → Hataları oku
2. SQL Editor → Test sorgularını çalıştır
3. Hata mesajını bana yaz

**Başarılı kurulum:**
```json
{
  "success": true,
  "processed": 5,
  "failed": 0
}
```

Bu yanıtı görüyorsan **TAMAM!** 🚀
