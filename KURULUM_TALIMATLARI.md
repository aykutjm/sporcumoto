# 🚀 Firebase Cloud Functions - Hızlı Kurulum

## ⚡ 3 Adımda Kurulum

### 1️⃣ Bağımlılıkları Yükle
```bash
cd C:\Users\adnan\Desktop\gitsporcum\functions
npm install
```

### 2️⃣ Firebase'e Giriş Yap
```bash
firebase login
```

### 3️⃣ Deploy Et
```bash
cd ..
firebase deploy --only functions
```

---

## ✅ Kurulum Tamamlandı!

Sistem artık **tarayıcı kapalı olsa bile** çalışacak:

- ⏰ **Her 5 dakikada**: Zamanlanmış mesajlar gönderilir
- 💰 **Her gün 09:00**: Ödeme hatırlatmaları
- 🎂 **Her gün 08:00**: Doğum günü kutlamaları

---

## 📱 Admin Panelden Mesaj Zamanla

1. WhatsApp sayfasına git
2. "⏰ Mesaj Zamanla" butonuna tıkla
3. Alıcı, mesaj ve zamanı seç
4. Gönder!

Mesaj belirtilen zamanda **otomatik gönderilecek**.

---

## 🔍 Kontrol Et

Firebase Console'dan logları izle:
```bash
firebase functions:log
```

Veya Firebase Console → Functions → Logs

---

## ⚠️ Önemli

- Firebase **Blaze** (ödeme planı) gerekir
- Aylık maliyet çok düşük (~$1-5)
- WhatsApp cihazı bağlı olmalı

---

Detaylı bilgi için: `FIREBASE_FUNCTIONS_KURULUM.md`

