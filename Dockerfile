FROM node:20-alpine

WORKDIR /app

# Healthcheck için curl ekle
RUN apk add --no-cache curl

# Tüm dosyalarý kopyala
COPY . .

# Dependencies yükle
RUN npm install --production

# Healthcheck: Process çalýþýyor mu kontrol et
HEALTHCHECK --interval=2m --timeout=10s --start-period=30s --retries=3 \
  CMD pgrep -f "node.*combined-auto-reply-system.js" > /dev/null || exit 1

# Birleþik script'i çalýþtýr
CMD ["node", "combined-auto-reply-system.js"]
