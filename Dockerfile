FROM node:20-alpine

WORKDIR /app

# Tüm dosyalarý kopyala
COPY . .

# Dependencies yükle
RUN npm install --production

# Birleþik script'i çalýþtýr
CMD ["node", "combined-auto-reply-system.js"]
