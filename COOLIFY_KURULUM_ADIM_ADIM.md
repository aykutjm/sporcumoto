# 🚀 COOLIFY KURULUM - ADIM ADIM REHBER

## ✅ HAZıRLIK DURUMU

### Kontrol Edilenler:
- ✅ Supabase bağlantısı çalışıyor (`https://supabase.edu-ai.online`)
- ✅ `combined-auto-reply-system.js` hazır
- ✅ `Dockerfile` hazır
- ✅ `docker-compose.yml` hazır
- ✅ `.dockerignore` hazır
- ✅ Bilgisayar cronjob'ı kaldırıldı (`Sporcum-AutoReply`)

---

## 📦 ADIM 1: DOSYALARI HAZIRLAMA

Coolify'a upload edeceğimiz dosyalar:

```
sporcum-supabase/
├── Dockerfile                        ✅ Hazır
├── docker-compose.yml                ✅ Hazır
├── .dockerignore                     ✅ Hazır
├── combined-auto-reply-system.js     ✅ Hazır
├── package.json                      ✅ Hazır
└── package-lock.json                 ✅ Hazır
```

**Bu dosyaları tek bir klasöre kopyalayalım:**

```powershell
# Yeni klasör oluştur
New-Item -ItemType Directory -Path "C:\Users\adnan\Desktop\coolify-deploy" -Force

# Gerekli dosyaları kopyala
Copy-Item "Dockerfile" "C:\Users\adnan\Desktop\coolify-deploy\"
Copy-Item "docker-compose.yml" "C:\Users\adnan\Desktop\coolify-deploy\"
Copy-Item ".dockerignore" "C:\Users\adnan\Desktop\coolify-deploy\"
Copy-Item "combined-auto-reply-system.js" "C:\Users\adnan\Desktop\coolify-deploy\"
Copy-Item "package.json" "C:\Users\adnan\Desktop\coolify-deploy\"
Copy-Item "package-lock.json" "C:\Users\adnan\Desktop\coolify-deploy\"

Write-Host "✅ Dosyalar coolify-deploy klasörüne kopyalandı!" -ForegroundColor Green
```

---

## 🌐 ADIM 2: COOLIFY DASHBOARD'A GİRİŞ

1. **Coolify adresinizi açın**
   - URL: `https://coolify.your-domain.com` (kendi adresinizi yazın)
   - Veya: `http://YOUR_SERVER_IP:8000`

2. **Login yapın**
   - Username/Email ile giriş yapın

---

## 📁 ADIM 3: YENİ PROJE OLUŞTURMA

### 3.1 - Proje Seçimi
```
1. Sol menüden "Projects" seçin
2. Mevcut bir proje varsa seçin
   VEYA
3. "+ New Project" butonuna tıklayın
```

### 3.2 - Yeni Proje Ayarları (eğer yeni oluşturuyorsanız)
```
Name: Sporcum
Description: Spor salonu yönetim sistemi
```

---

## 🐳 ADIM 4: DOCKER COMPOSE RESOURCE EKLEME

### 4.1 - Resource Ekleme
```
1. Proje içinde "+ New Resource" butonuna tıklayın
2. "Docker Compose" seçeneğini seçin
```

### 4.2 - Genel Ayarlar
```
Name: auto-reply-system
Description: Cevapsız aramalara otomatik WhatsApp mesajı gönderen sistem
```

### 4.3 - Source Seçimi

**YÖNTEcM 1: GIT REPOSITORY (ÖNERİLİR)**

Eğer GitHub kullanmak istiyorsanız:

```powershell
# 1. GitHub repo oluşturun: https://github.com/new
# Repo adı: sporcum-auto-reply

# 2. Git push yapın:
cd C:\Users\adnan\Desktop\Projeler\sporcum-supabase

git init
git add Dockerfile docker-compose.yml .dockerignore combined-auto-reply-system.js package.json package-lock.json
git commit -m "Coolify deployment setup"
git remote add origin https://github.com/KULLANICI_ADINIZ/sporcum-auto-reply.git
git branch -M main
git push -u origin main
```

Coolify'da:
```
Source Type: Git Repository
Repository: https://github.com/KULLANICI_ADINIZ/sporcum-auto-reply
Branch: main
```

**YÖNTEM 2: MANUEL UPLOAD (DAHA KOLAY)**

Coolify'da:
```
1. "Upload docker-compose.yml" seçeneğini seçin
2. C:\Users\adnan\Desktop\coolify-deploy klasöründeki dosyaları upload edin
```

---

## 🔐 ADIM 5: ENVIRONMENT VARIABLES AYARLAMA

**ÖNEMLİ: Coolify'da environment variables ekleyin!**

```
Resource > Environment Variables bölümüne gidin
"+Add" butonuna tıklayın
```

### Eklenecek Değişkenler:

```env
SUPABASE_URL=https://supabase.edu-ai.online

SUPABASE_SERVICE_ROLE_KEY=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzdXBhYmFzZSIsImlhdCI6MTc2MjEwNTMyMCwiZXhwIjo0OTE3Nzc4OTIwLCJyb2xlIjoiYW5vbiJ9.HXUza0GT82-trWkx0WWKe-nY7KsGrIjIHSOJPKsOHjs
```

**NOT:** Her satır için "+ Add Variable" butonuna tıklayın

---

## 🚀 ADIM 6: DEPLOYMENT BAŞLATMA

### 6.1 - Build & Deploy
```
1. Sağ üstteki "Deploy" butonuna tıklayın
2. İlk build 2-3 dakika sürebilir
3. Logs kısmından ilerlemeyi izleyin
```

### 6.2 - Log Kontrolleri

Build sırasında şunları görmelisiniz:
```
✅ Building Docker image...
✅ Installing dependencies...
✅ Starting container...
✅ Container running!
```

Container çalıştıktan sonra:
```
✅ Mesaj kuyruğu işleniyor...
✅ Cevapsız aramalar kontrol ediliyor...
Sleeping for 2 minutes...
```

---

## 📊 ADIM 7: SİSTEM KONTROLÜ

### 7.1 - Container Loglarını İzleme

Coolify Dashboard'da:
```
1. Resource'u açın
2. "Logs" sekmesine gidin
3. Real-time logları izleyin
```

Göreceğiniz loglar:
```
🔄 Birleşik Otomatik Cevap Sistemi başlatılıyor...
⏰ Başlangıç zamanı: 2024-01-...

=== BÖLÜM 1: CEVAPSIZ ARAMALAR ===
🔍 Cevapsız aramalar kontrol ediliyor...
✅ X adet cevapsız arama bulundu
...

=== BÖLÜM 2: MESAJ KUYRUĞU ===
🔄 Mesaj kuyruğu işleniyor...
✅ X adet mesaj gönderildi
...

✅ İşlem tamamlandı!
Sleeping for 2 minutes...
```

### 7.2 - Supabase'de Kontrol

Supabase Dashboard > SQL Editor:

```sql
-- Son 10 kuyruk kaydını gör
SELECT 
  id,
  status,
  to_number,
  created_at,
  sent_at
FROM message_queue
ORDER BY created_at DESC
LIMIT 10;

-- Status dağılımı
SELECT 
  status,
  COUNT(*) as count
FROM message_queue
GROUP BY status;
```

---

## ✅ ADIM 8: DOĞRULAMA

### Başarılı Kurulum Kriterleri:

- [ ] Container "Running" durumunda
- [ ] Loglar her 2 dakikada bir yenileniyor
- [ ] Supabase'de `message_queue` tablosu dolmaya başladı
- [ ] WhatsApp mesajları gönderiliyor (`status = sent`)
- [ ] Hata logları yok veya çok az

---

## 🔧 SORUN GİDERME

### Problem 1: Container Başlamıyor

**Çözüm:**
```
1. Logs'u kontrol edin
2. Environment variables doğru mu?
3. Supabase bağlantısını test edin
```

### Problem 2: "Cannot find module" Hatası

**Çözüm:**
```
1. package.json'da dependencies var mı?
2. Dockerfile'da "npm install" çalışıyor mu?
3. Build loglarını kontrol edin
```

### Problem 3: Mesajlar Gönderilmiyor

**Çözüm:**
```
1. message_queue tablosunda pending kayıt var mı?
2. Evolution API çalışıyor mu?
3. WhatsApp device bağlı mı?
```

### Problem 4: "ECONNREFUSED" - Supabase Bağlantı Hatası

**Çözüm:**
```
1. SUPABASE_URL doğru mu?
2. SUPABASE_SERVICE_ROLE_KEY doğru mu?
3. Coolify sunucusu Supabase'e erişebiliyor mu?
```

---

## 📱 ADIM 9: İZLEME VE BAKIM

### Günlük Kontroller:

```sql
-- Bugün gönderilen mesaj sayısı
SELECT COUNT(*) as sent_today
FROM message_queue
WHERE status = 'sent'
  AND DATE(sent_at) = CURRENT_DATE;

-- Başarısız mesajlar
SELECT COUNT(*) as failed_today
FROM message_queue
WHERE status = 'failed'
  AND DATE(created_at) = CURRENT_DATE;
```

### Haftalık Kontroller:

```
1. Container memory kullanımı normal mi?
2. Log dosyası boyutu aşırı büyüdü mü?
3. Hata oranı %5'in altında mı?
```

---

## 🎉 KURULUM TAMAMLANDI!

**Artık sisteminiz:**
- ✅ 7/24 çalışıyor
- ✅ PC kapalı olsa bile çalışmaya devam ediyor
- ✅ Her 2 dakikada bir:
  - Cevapsız aramaları kontrol ediyor
  - Mesaj kuyruğunu işliyor
  - WhatsApp mesajları gönderiyor
- ✅ Mesajlar kaybolmuyor (kuyruk sistemi)
- ✅ Tekrar deneme mekanizması var (failed → retry)

---

## 📞 DESTEK

Sorun yaşarsanız:

1. **Container loglarını kontrol edin**
2. **Supabase message_queue tablosunu kontrol edin**
3. **Environment variables'ı doğrulayın**
4. **Bu rehberin "Sorun Giderme" bölümüne bakın**
