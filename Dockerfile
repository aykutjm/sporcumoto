FROM node:20-alpine

WORKDIR /app

# Curl ekle (healthcheck için)
RUN apk add --no-cache curl

# Tüm dosyalarý kopyala
COPY . .

# Dependencies yükle
RUN npm install --production

# Healthcheck ekle
HEALTHCHECK --interval=5m --timeout=3s --start-period=10s \
  CMD curl -f http://localhost/ || exit 0

# Birleþik script'i çalýþtýr
CMD ["node", "combined-auto-reply-system.js"]
