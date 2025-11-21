# Coolify'da Cron Job Kurulumu
## PC Kapalıyken de Otomatik Mesaj Gönderimi

### ✅ Neden Coolify?
- 7/24 açık sunucu (VPS)
- PC kapalı olsa da çalışır
- Supabase ile aynı ortamda
- Ücretsiz (Coolify self-hosted)

---

## 🔧 Kurulum Adımları:

### 1. Coolify Dashboard'a Giriş Yapın
- Coolify panel: https://coolify.sizin-domain.com
- Login yapın

### 2. Yeni Scheduled Task (Cron) Oluşturun
```
Coolify Dashboard > Your Server > + Add Resource > Scheduled Task
```

### 3. Cron Job Ayarları:
- **Name:** `sporcum-auto-reply`
- **Command:** 
```bash
cd /app && node auto-reply-missed-calls.js
```
- **Schedule (Cron):** `*/2 * * * *` (her 2 dakika)
- **Container:** Supabase ile aynı network'te olmalı

### 4. Environment Variables (.env):
```env
SUPABASE_URL=https://supabase.edu-ai.online
SUPABASE_SERVICE_ROLE_KEY=eyJ0eXAiOiJKV1QiLCJhbGci...
```

### 5. Dockerfile (Node.js için):
```dockerfile
FROM node:20-alpine

WORKDIR /app

# Package files
COPY package.json package-lock.json ./
RUN npm install --production

# Script dosyası
COPY auto-reply-missed-calls.js .
COPY .env .

CMD ["node", "auto-reply-missed-calls.js"]
```

### 6. Deploy
- "Deploy" butonuna tıklayın
- Her 2 dakikada otomatik çalışacak
- Logs'tan takip edebilirsiniz

---

## 📊 Avantajları:
✅ PC kapalı olsa da çalışır
✅ 7/24 aktif
✅ Supabase ile aynı sunucuda (hızlı)
✅ Coolify'dan logs görürsünüz
✅ Restart/stop kolay

## 🔍 Monitoring:
```bash
# Coolify Logs
Coolify > Scheduled Tasks > sporcum-auto-reply > Logs

# Manuel test:
Coolify > Terminal > node auto-reply-missed-calls.js
```

---

## ⚙️ Alternatif: Docker Compose
Eğer Coolify'da scheduled task yoksa, Docker container olarak:

```yaml
version: '3.8'
services:
  auto-reply-cron:
    image: node:20-alpine
    working_dir: /app
    volumes:
      - ./auto-reply-missed-calls.js:/app/auto-reply-missed-calls.js
      - ./package.json:/app/package.json
      - ./.env:/app/.env
    command: sh -c "npm install && while true; do node auto-reply-missed-calls.js; sleep 120; done"
    restart: always
    environment:
      - SUPABASE_URL=${SUPABASE_URL}
      - SUPABASE_SERVICE_ROLE_KEY=${SUPABASE_SERVICE_ROLE_KEY}
```

Deploy:
```bash
docker-compose up -d
```
