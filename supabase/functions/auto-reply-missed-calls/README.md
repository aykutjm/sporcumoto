# Supabase Edge Function - Auto Reply to Missed Calls

Bu Edge Function, cevapsız çağrılara otomatik WhatsApp mesajı gönderir.

## 🚀 Kurulum

### 1. Supabase CLI Kurulumu

```powershell
# Scoop ile (önerilen)
scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
scoop install supabase

# Veya direkt indirin:
# https://github.com/supabase/cli/releases
```

### 2. Supabase'e Giriş

```powershell
supabase login
```

### 3. Projeyi Bağla

```powershell
# Project ID'nizi Supabase Dashboard'dan alın
supabase link --project-ref YOUR_PROJECT_ID
```

### 4. Edge Function Deploy

```powershell
cd c:\Users\adnan\Desktop\Projeler\sporcum-supabase
supabase functions deploy auto-reply-missed-calls
```

### 5. Secrets Ayarla

```powershell
# Supabase Dashboard > Project Settings > API
# SUPABASE_URL ve SUPABASE_SERVICE_ROLE_KEY otomatik tanımlı
```

## ⏰ Cron Job Kurulumu (Otomatik Çalıştırma)

Supabase Dashboard'da:

1. **Database > Extensions** > `pg_cron` enable edin
2. **SQL Editor**'de şu komutu çalıştırın:

```sql
-- Her 2 dakikada bir otomatik çalıştır
SELECT cron.schedule(
  'auto-reply-missed-calls',
  '*/2 * * * *', -- Her 2 dakika
  $$
  SELECT
    net.http_post(
      url:='https://YOUR_PROJECT_REF.supabase.co/functions/v1/auto-reply-missed-calls',
      headers:='{"Content-Type": "application/json", "Authorization": "Bearer YOUR_ANON_KEY"}'::jsonb,
      body:='{}'::jsonb
    ) as request_id;
  $$
);
```

**DİKKAT:** `YOUR_PROJECT_REF` ve `YOUR_ANON_KEY` değerlerini değiştirin!

## 🔍 Test

```powershell
# Manuel test
supabase functions serve auto-reply-missed-calls
```

Başka bir terminal:

```powershell
curl -i --location --request POST 'http://localhost:54321/functions/v1/auto-reply-missed-calls' \
  --header 'Authorization: Bearer YOUR_ANON_KEY' \
  --header 'Content-Type: application/json'
```

## 📊 Log Kontrolü

```powershell
supabase functions logs auto-reply-missed-calls
```

## ⚙️ Gerekli Supabase Tabloları

Edge function şu tabloları kullanır:

- ✅ `clubs` - Kulüp ayarları
- ✅ `whatsappDevices` - WhatsApp cihazları
- ✅ `messageQueue` - Mesaj kuyruğu
- ✅ `messageTemplates` - CRM mesaj şablonları
- 🆕 `autoReplySent` - Gönderilen otomatik mesajlar (oluşturun!)

### autoReplySent Tablosu:

```sql
CREATE TABLE IF NOT EXISTS autoReplySent (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  clubId TEXT NOT NULL,
  phone TEXT NOT NULL,
  formattedPhone TEXT NOT NULL,
  sentDate TIMESTAMP WITH TIME ZONE NOT NULL,
  callTime TEXT,
  deviceUsed TEXT,
  createdAt TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index ekle (performans için)
CREATE INDEX idx_autoreplysent_club_date ON autoReplySent(clubId, sentDate);
CREATE INDEX idx_autoreplysent_phone ON autoReplySent(phone);
```

## 🎯 Özellikler

- ✅ Çalışma saati kontrolü (clubSettings'den)
- ✅ Eşleşen WhatsApp cihazından gönderim
- ✅ Günlük duplicate kontrolü
- ✅ CRM mesaj şablonu kullanımı
- ✅ Multi-kulüp desteği
- ✅ Sayfa kapalıyken çalışır
- ✅ Her 2 dakikada otomatik kontrol

## 🐛 Sorun Giderme

**Edge function çalışmıyor?**
```powershell
supabase functions logs auto-reply-missed-calls --tail
```

**Cron job çalışmıyor?**
```sql
-- Cron job listesini kontrol et
SELECT * FROM cron.job;

-- Job'ı sil ve yeniden oluştur
SELECT cron.unschedule('auto-reply-missed-calls');
```
