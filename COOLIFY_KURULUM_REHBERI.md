# 🚀 Coolify'da Otomatik Mesaj Sistemi Kurulumu
## PC Kapalı Olsa Da 7/24 Çalışacak - Kuyruk Sistemi ile

---

## 📋 HAZIRLANAN BELGELER:
✅ `Dockerfile` - Docker image tanımı
✅ `docker-compose.yml` - Container orchestration
✅ `.dockerignore` - Gereksiz dosyaları hariç tut
✅ `combined-auto-reply-system.js` - **BİRLEŞİK SİSTEM** (cevapsız arama + mesaj gönderme)
✅ `whatsapp-queue-processor.js` - Sadece kuyruk işleyici (opsiyonel)
✅ `package.json` - Node.js dependencies

---

## 🔄 SİSTEM NASIL ÇALIŞIR?

**Her 2 dakikada bir otomatik olarak:**

### 1️⃣ CEVAPSIZ ARAMALARI KONTROL EDER
- Bulutfon API'den cevapsız aramaları çeker
- Mesaj gönderme saatlerini kontrol eder (messageSendingHours)
- Aynı gün aynı şablonun tekrar gönderilmesini engeller
- Mesajları `messageQueue` tablosuna **EKLER** (status: pending)

### 2️⃣ KUYRUKTAKİ MESAJLARI GÖNDERİR
- `messageQueue` tablosundaki `pending` mesajları alır
- Evolution API'ye WhatsApp mesajı **GÖNDERİR**
- Başarılı olan mesajların status'unu `sent` yapar
- Başarısız olanları `failed` olarak işaretler

**✨ PC kapalı olsa da, elektrik kesintisi olsa da çalışmaya devam eder!**
**✨ Kuyruk sistemi sayesinde mesajlar kaybolmaz, tekrar dener!**

---

## 🔧 ADIM ADIM KURULUM:

### 1️⃣ GitHub Repository Oluştur (Opsiyonel)

**A) Eğer GitHub kullanacaksanız:**
```powershell
# Git init (eğer yoksa)
cd C:\Users\adnan\Desktop\Projeler\sporcum-supabase
git init
git add Dockerfile docker-compose.yml combined-auto-reply-system.js whatsapp-queue-processor.js package.json package-lock.json
git commit -m "Coolify auto-reply queue system setup"

# GitHub'a push
git remote add origin https://github.com/KULLANICI_ADINIZ/sporcum-auto-reply.git
git branch -M main
git push -u origin main
```

**B) Veya Coolify'a direkt upload edin** (daha kolay!)

---

### 2️⃣ Coolify Dashboard'a Giriş

1. Coolify adresinize gidin: `https://coolify.your-domain.com`
2. Login yapın

---

### 3️⃣ Yeni Resource Ekle

**Coolify Dashboard'da:**

```
1. Sol menüden "Projects" seçin
2. Mevcut projenizi açın (veya + New Project)
3. "+ Add Resource" butonuna tıklayın
4. "Docker Compose" seçin
```

---

### 4️⃣ Docker Compose Ayarları

**General:**
- **Name:** `sporcum-auto-reply`
- **Description:** `Cevapsız aramalara otomatik WhatsApp mesajı gönderen sistem`

**Source:**
- **Method 1 - GitHub (önerilir):**
  - Repository: `https://github.com/KULLANICI_ADINIZ/sporcum-auto-reply`
  - Branch: `main`
  
- **Method 2 - Upload:**
  - "Upload docker-compose.yml" seçeneğini kullanın

**Docker Compose File:**
```yaml
version: '3.8'

services:
  auto-reply-cron:
    build: .
    container_name: sporcum-auto-reply
    restart: always
    environment:
      - SUPABASE_URL=${SUPABASE_URL}
      - SUPABASE_SERVICE_ROLE_KEY=${SUPABASE_SERVICE_ROLE_KEY}
    command: sh -c "while true; do node auto-reply-missed-calls.js; echo 'Sleeping for 2 minutes...'; sleep 120; done"
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

---

### 5️⃣ Environment Variables Ekle

**Coolify'da Resource > Environment Variables:**

```env
SUPABASE_URL=https://supabase.edu-ai.online
SUPABASE_SERVICE_ROLE_KEY=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN1cGFiYXNlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzIxMjg2MDAsImV4cCI6MjA0NzcwNDYwMH0.xxx
```

**Not:** Service role key'i Coolify Supabase ayarlarından alın!

---

### 6️⃣ Deploy!

1. "Deploy" butonuna tıklayın
2. Build loglarını izleyin:
   ```
   Building image...
   Installing dependencies...
   Starting container...
   ✅ Container started successfully
   ```

---

## ✅ KONTROL VE İZLEME

### Logs İzleme
**Coolify Dashboard:**
```
Resources > sporcum-auto-reply > Logs
```

Göreceğiniz çıktı:
```
🚀 Auto-reply script başlatıldı: 20.11.2025 23:30:15
📊 1 aktif kulüp bulundu
🏢 Kulüp kontrol ediliyor: FmvoFvTCek44CR3pS4XC
  ✅ 1 WhatsApp cihazı bulundu
  📞 2 cevapsız çağrı bulundu
  ✅ Mesaj kuyruğa eklendi: 05355087586
✅ İşlem tamamlandı: 2 mesaj kuyruğa eklendi
Sleeping for 2 minutes...
```

### Manuel Test
**Coolify Terminal:**
```bash
# Container'a bağlan
docker exec -it sporcum-auto-reply sh

# Manuel çalıştır
node auto-reply-missed-calls.js

# Çıkış
exit
```

### Container Durumu
```bash
# Coolify sunucusunda
docker ps | grep sporcum-auto-reply

# Logs
docker logs -f sporcum-auto-reply

# Restart
docker restart sporcum-auto-reply
```

---

## 🎯 AVANTAJLAR

| Özellik | Durum |
|---------|-------|
| 7/24 Çalışma | ✅ |
| PC Kapalı Çalışır | ✅ |
| Otomatik Restart | ✅ |
| Log İzleme | ✅ |
| Ücretsiz | ✅ |
| Supabase ile Aynı Network | ✅ |

---

## 🔄 GÜNCELLEME

**Kod değiştirdiğinizde:**

```powershell
# GitHub kullanıyorsanız
git add auto-reply-missed-calls.js
git commit -m "Update: mesai saati kontrolü eklendi"
git push

# Coolify'da
Resources > sporcum-auto-reply > Redeploy
```

**Veya Coolify'da manuel update:**
```
1. Resource > Stop
2. Upload new docker-compose.yml
3. Deploy
```

---

## ⚙️ GELİŞMİŞ AYARLAR

### Cron Schedule Değiştir (örn: 5 dakika)
`docker-compose.yml`:
```yaml
command: sh -c "while true; do node auto-reply-missed-calls.js; sleep 300; done"
#                                                                    ^^^ 5 dakika
```

### Sadece Belirli Saatlerde Çalıştır
`docker-compose.yml`:
```yaml
command: sh -c "while true; do
  HOUR=$(date +%H);
  if [ $HOUR -ge 9 ] && [ $HOUR -lt 18 ]; then
    node auto-reply-missed-calls.js;
  fi;
  sleep 120;
done"
```

### Email Bildirimi Ekle (hata durumunda)
Script'e ekle:
```javascript
catch (error) {
  console.error('❌ Hata:', error);
  // Buraya email gönderme kodu
  process.exit(1); // Container restart olur
}
```

---

## 🆘 SORUN GİDERME

### Container Başlamıyor
```bash
# Logs kontrol
docker logs sporcum-auto-reply

# Muhtemel sorun: Environment variables
# Coolify'da SUPABASE_URL ve KEY'i kontrol edin
```

### Script Hata Veriyor
```bash
# Container'a gir
docker exec -it sporcum-auto-reply sh

# Manuel test
node auto-reply-missed-calls.js

# Dependencies kontrol
npm list
```

### Her 2 Dakikada Çalışmıyor
```bash
# Logs'ta "Sleeping for 2 minutes..." görünüyor mu?
docker logs -f sporcum-auto-reply --tail 50
```

---

## 📞 DESTEK

Sorun olursa:
1. Coolify logs'u kontrol edin
2. `docker logs sporcum-auto-reply` çalıştırın
3. GitHub Issues'da sorun açın

---

✅ **HAZIR!** Artık sistem 7/24 çalışacak, PC kapalı olsa bile!
