# 🖥️ Kendi Sunucunuzda Kurulum

Node.js script olarak çalıştırıp, cron job ile otomatikleştirebilirsiniz.

---

## 📋 KURULUM ADIMLARI

### 1. Gerekli Paketleri Kurun

```powershell
cd c:\Users\adnan\Desktop\Projeler\sporcum-supabase

npm install @supabase/supabase-js node-fetch dotenv
```

### 2. .env Dosyası Oluşturun

```powershell
# .env.example dosyasını kopyalayın
copy .env.example .env
```

`.env` dosyasını düzenleyin ve şu değerleri girin:

```
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Değerleri buradan alın:**
- Supabase Dashboard > Settings > API > Project URL
- Supabase Dashboard > Settings > API > service_role key (⚠️ Secret!)

### 3. Veritabanı Tablosunu Oluşturun

Supabase Dashboard > SQL Editor'de çalıştırın:

```powershell
# Dosyayı açın ve SQL'i kopyalayın
notepad create-autoReplySent-table-CLEAN.sql
```

### 4. Script'i Test Edin

```powershell
node auto-reply-missed-calls.js
```

**Beklenen çıktı:**
```
🚀 Auto-reply script başlatıldı: 20.11.2025 15:30:00
📊 1 aktif kulüp bulundu

🏢 Kulüp kontrol ediliyor: FmvoFvTCek44CR3pS4XC
  ✅ 2 WhatsApp cihazı bulundu
  📞 3 cevapsız çağrı bulundu
  ✅ Mesaj kuyruğa eklendi: 05515046792 (Kulup)

✅ İşlem tamamlandı: 1 mesaj kuyruğa eklendi
⏰ Bitiş: 20.11.2025 15:30:05
```

---

## ⏰ OTOMATİK ÇALIŞTIRMA (CRON JOB)

### Windows Task Scheduler (Önerilen)

#### 1. Batch Script Oluşturun

`run-auto-reply.bat` dosyası oluşturun:

```batch
@echo off
cd /d C:\Users\adnan\Desktop\Projeler\sporcum-supabase
node auto-reply-missed-calls.js >> auto-reply.log 2>&1
```

#### 2. Task Scheduler'ı Açın

```powershell
taskschd.msc
```

#### 3. Yeni Task Oluşturun

1. **Create Basic Task** tıklayın
2. **Name:** Auto Reply Missed Calls
3. **Trigger:** Daily
4. **Repeat task every:** 2 minutes
5. **Duration:** Indefinitely
6. **Action:** Start a program
7. **Program:** `C:\Users\adnan\Desktop\Projeler\sporcum-supabase\run-auto-reply.bat`
8. **Finish** tıklayın

#### 4. Gelişmiş Ayarlar

Task'a sağ tıklayıp **Properties**:
- **General** > ✅ Run whether user is logged on or not
- **Triggers** > Edit > ✅ Repeat task every: **2 minutes**
- **Settings** > ✅ If task is already running: **Do not start a new instance**

---

### Alternatif: PM2 ile (Node.js Process Manager)

```powershell
# PM2 kurun
npm install -g pm2

# Script'i PM2 ile başlatın (2 dakikada bir çalışacak şekilde)
pm2 start auto-reply-missed-calls.js --cron "*/2 * * * *" --name "auto-reply"

# PM2'yi Windows başlangıcına ekleyin
pm2 startup
pm2 save
```

**PM2 Komutları:**
```powershell
pm2 status              # Durum kontrol
pm2 logs auto-reply     # Log görüntüle
pm2 restart auto-reply  # Yeniden başlat
pm2 stop auto-reply     # Durdur
pm2 delete auto-reply   # Sil
```

---

## 📊 LOG KONTROLÜ

### Log Dosyası

```powershell
# Son 20 satır
Get-Content auto-reply.log -Tail 20

# Canlı takip
Get-Content auto-reply.log -Wait -Tail 20
```

### Veritabanı Kontrolü

Supabase Dashboard > SQL Editor:

```sql
-- Bugün gönderilen mesajlar
SELECT * FROM autoReplySent 
WHERE DATE(sentDate) = CURRENT_DATE 
ORDER BY createdAt DESC;

-- Mesaj kuyruğu
SELECT * FROM messageQueue 
WHERE type = 'auto_reply_missed_call' 
ORDER BY createdAt DESC 
LIMIT 10;
```

---

## 🔧 SORUN GİDERME

### "Error: Cannot find module '@supabase/supabase-js'"

```powershell
npm install @supabase/supabase-js node-fetch dotenv
```

### "Error: SUPABASE_URL is not defined"

`.env` dosyasını oluşturun ve değerleri girin.

### "Bulutfon API error: 401"

`clubs` tablosunda `settings.bulutfonApiKey` kontrolü yapın:

```sql
SELECT id, settings->'bulutfonApiKey' as api_key FROM clubs;
```

### "WhatsApp cihazı yok"

```sql
SELECT * FROM whatsappDevices WHERE status = 'active';
```

---

## ✅ AVANTAJLAR

✅ **Kendi sunucunuzda çalışır** - Supabase Edge Functions'a gerek yok  
✅ **Windows Task Scheduler** - Her 2 dakikada otomatik  
✅ **Log dosyası** - Tüm işlemler kaydedilir  
✅ **PM2 desteği** - Process management  
✅ **Sayfa kapalı** - Arka planda çalışır  

---

## 🎯 ÖZELLİKLER

- ✅ Çalışma saati kontrolü (clubSettings'den)
- ✅ Eşleşen WhatsApp cihazından gönderim
- ✅ Günlük duplicate kontrolü
- ✅ CRM mesaj şablonu kullanımı
- ✅ Multi-kulüp desteği
- ✅ Türkçe tarih formatı (DD.MM.YYYY HH:MM)

---

**Kurulum tamamlandı!** 🎉
