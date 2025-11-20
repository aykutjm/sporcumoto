FROM node:20-alpine

WORKDIR /app

# Package files kopyala
COPY package*.json ./

# Dependencies yükle
RUN npm install --production

# Script dosyalarını kopyala
COPY combined-auto-reply-system.js .
COPY whatsapp-queue-processor.js .

# Healthcheck ekle
HEALTHCHECK --interval=5m --timeout=3s \
  CMD node -e "console.log('healthy')" || exit 1

# Birleşik script'i çalıştır
CMD ["node", "combined-auto-reply-system.js"]
