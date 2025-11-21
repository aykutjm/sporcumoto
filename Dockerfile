FROM node:20-alpine

WORKDIR /app

# procps paketi yukle (pgrep icin gerekli)
RUN apk add --no-cache procps

# Tum dosyalari kopyala
COPY . .

# Dependencies yukle
RUN npm install --production

# Script'i calistir
CMD ["node", "combined-auto-reply-system.js"]
