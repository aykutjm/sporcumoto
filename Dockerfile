FROM node:20-alpine

WORKDIR /app

# Package files kopyala
COPY package*.json ./

# Dependencies yükle
RUN npm install --production

# Script dosyasýný kopyala
COPY combined-auto-reply-system.js .

# Healthcheck ekle
HEALTHCHECK --interval=5m --timeout=3s \
  CMD node -e "console.log('healthy')" || exit 1

# Birleþik script'i çalýþtýr
CMD ["node", "combined-auto-reply-system.js"]
