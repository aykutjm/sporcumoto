FROM node:20-alpine

WORKDIR /app

# Tüm dosyalarý kopyala
COPY . .

# Dependencies yükle
RUN npm install --production

# Healthcheck ekle
HEALTHCHECK --interval=5m --timeout=3s \
  CMD node -e "console.log('healthy')" || exit 1

# Birleþik script'i çalýþtýr
CMD ["node", "combined-auto-reply-system.js"]
