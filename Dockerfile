FROM node:20-alpine

# Timezone ayarla (Türkiye)
ENV TZ=Europe/Istanbul

WORKDIR /app

# procps paketi yukle (pgrep icin gerekli)
RUN apk add --no-cache procps tzdata

# Tum dosyalari kopyala
COPY . .

# Dependencies yukle
RUN npm install --production

# 2 dakikada bir calistir
CMD ["sh", "-c", "while true; do node combined-auto-reply-system.js; echo 'Sleeping for 2 minutes...'; sleep 120; done"]
