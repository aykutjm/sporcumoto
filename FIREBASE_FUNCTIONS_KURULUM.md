# 🚀 Firebase Cloud Functions Kurulum Rehberi

## 📋 Genel Bakış

Bu sistem, **tarayıcı kapalı olsa bile** arka planda otomatik mesaj gönderimi sağlar:
- ⏰ Zamanlanmış mesajlar (her 5 dakikada kontrol)
- 💰 Ödeme hatırlatmaları (günlük saat 09:00)
- 🎂 Doğum günü mesajları (günlük saat 08:00)

---

## 🛠️ Kurulum Adımları

### 1. Node.js Kurulumu
Eğer yoksa [Node.js](https://nodejs.org/) indirip yükleyin (v18 veya üzeri)

```bash
node --version  # Kontrol et
```

### 2. Firebase CLI Kurulumu

```bash
npm install -g firebase-tools
```

### 3. Firebase'e Giriş

```bash
firebase login
```

### 4. Firebase Projesini Seç

```bash
cd C:\Users\adnan\Desktop\gitsporcum
firebase use sporcum-crm
```

**Not:** Eğer proje ID'niz farklıysa `.firebaserc` dosyasını düzenleyin:
```json
{
  "projects": {
    "default": "SIZIN_PROJE_ID"
  }
}
```

### 5. Bağımlılıkları Yükle

```bash
cd functions
npm install
```

### 6. Functions'ı Deploy Et

```bash
firebase deploy --only functions
```

---

## 📊 Firebase Koleksiyonları

### `scheduledMessages` - Zamanlanmış Mesajlar

Bu koleksiyon, ileride gönderilecek mesajları saklar.

```javascript
{
  clubId: "FmvoFvTCek44CR3pS4XC",
  deviceId: "whatsapp-device-id",
  recipientName: "Ahmet Yılmaz",
  phoneNumber: "05421234567",
  messageText: "Mesaj içeriği...",
  messageType: "payment-reminder", // veya "birthday", "task", "custom"
  scheduledTime: Timestamp,  // Ne zaman gönderilecek
  status: "scheduled",  // "scheduled", "sent", "failed"
  createdAt: Timestamp,
  sentAt: Timestamp (opsiyonel),
  error: string (opsiyonel),
  retryCount: 0
}
```

### Admin Panelinden Mesaj Zamanlama Örneği

```javascript
// JavaScript console'da test için:
await window.firebase.addDoc(
  window.firebase.collection(window.db, 'scheduledMessages'), 
  {
    clubId: currentClubId,
    deviceId: whatsappDevices[0].id,
    recipientName: "Test Kullanıcı",
    phoneNumber: "05421234567",
    messageText: "Bu bir test mesajıdır",
    messageType: "custom",
    scheduledTime: new Date(Date.now() + 10 * 60 * 1000), // 10 dakika sonra
    status: "scheduled",
    createdAt: new Date(),
    retryCount: 0
  }
);
```

---

## ⚙️ Cloud Functions Açıklaması

### 1. `scheduledMessageSender` - Her 5 Dakikada Çalışır

- `scheduledMessages` koleksiyonunu kontrol eder
- `status: "scheduled"` ve `scheduledTime <= şimdi` olan mesajları gönderir
- Başarılı olanları `status: "sent"` yapar
- Başarısız olanları `status: "failed"` yapar ve hata kaydeder

### 2. `dailyPaymentReminders` - Her Gün Saat 09:00

- Tüm kulüplerin vadesi geçmiş ödemelerini kontrol eder
- Her 7 günde bir hatırlatma zamanlar
- Mesaj şablonlarını kullanır

### 3. `dailyBirthdayMessages` - Her Gün Saat 08:00

- Bugün doğum günü olan üyeleri bulur
- Her birine kutlama mesajı zamanlar

---

## 📱 Admin Paneline Entegrasyon

### Zamanlanmış Mesaj Gönderme Butonu Ekle

`admin.html` dosyasına eklenebilecek örnek fonksiyon:

```javascript
async function scheduleMessage(phoneNumber, message, delayMinutes = 10) {
    try {
        // Default cihazı al
        const device = whatsappDevices.find(d => 
            d.status === 'connected' && d.instanceName === defaultWhatsAppDevice
        ) || whatsappDevices.find(d => d.status === 'connected');
        
        if (!device) {
            showAlert('Bağlı WhatsApp cihazı bulunamadı!', 'danger');
            return;
        }
        
        // Zamanlanmış mesaj oluştur
        const scheduledTime = new Date(Date.now() + delayMinutes * 60 * 1000);
        
        await window.firebase.addDoc(
            window.firebase.collection(window.db, 'scheduledMessages'), 
            {
                clubId: currentClubId,
                deviceId: device.id,
                recipientName: 'Alıcı Adı',
                phoneNumber: phoneNumber,
                messageText: message,
                messageType: 'custom',
                scheduledTime: scheduledTime,
                status: 'scheduled',
                createdAt: new Date(),
                retryCount: 0
            }
        );
        
        showAlert(`✅ Mesaj ${delayMinutes} dakika sonra gönderilmek üzere zamanlandı!`, 'success');
        
    } catch (error) {
        console.error('Mesaj zamanlama hatası:', error);
        showAlert('❌ Mesaj zamanlanamadı: ' + error.message, 'danger');
    }
}
```

---

## 🧪 Test Etme

### 1. Local Test (Emulator)

```bash
cd functions
npm install
firebase emulators:start --only functions
```

### 2. Production Test

Functions deploy edildikten sonra:

```bash
# Logları izle
firebase functions:log --only scheduledMessageSender
```

### 3. Manuel Trigger

Firebase Console → Functions → İlgili function → Logs → Test

---

## 📋 Kontrol Listesi

- [x] Firebase CLI kuruldu
- [x] Functions deploy edildi
- [x] `scheduledMessages` koleksiyonu oluşturuldu
- [x] WhatsApp cihazları bağlı
- [x] Mesaj şablonları ayarlandı
- [ ] Test mesajı gönderildi
- [ ] 5 dakika beklendi ve mesajın gittiği kontrol edildi

---

## ⚠️ Önemli Notlar

### 1. Maliyet
- Firebase'in **Blaze** (Pay as you go) planı gereklidir
- Her function çağrısı ücretsiz kotadan sayılır
- Düşük kullanımda çok düşük maliyet (aylık ~$1-5)

### 2. Rate Limiting
- Mesajlar arası 5 saniye bekleme var
- WhatsApp spam koruması için
- Gerekirse ayarlanabilir

### 3. Hata Yönetimi
- Başarısız mesajlar otomatik retry yapmaz
- Manuel kontrol gerekir
- `retryCount` alanı takip için

### 4. Timezone
- Tüm zamanlamalar **Europe/Istanbul** (GMT+3)
- Değiştirmek için function kodunda `timeZone` parametresini değiştirin

---

## 🔧 Sorun Giderme

### "Function deploy edilemiyor"
```bash
# Firebase projesini kontrol et
firebase projects:list

# Doğru projeye switch et
firebase use sporcum-crm
```

### "scheduledMessageSender çalışmıyor"
```bash
# Logları kontrol et
firebase functions:log --only scheduledMessageSender

# Function'ı manuel tetikle
firebase functions:shell
> scheduledMessageSender()
```

### "Mesajlar gönderilmiyor"
1. `whatsappDevices` koleksiyonunda cihazın `status: "connected"` olduğundan emin ol
2. `evolutionUrl` ve `apiKey` doğru mu kontrol et
3. Firebase Console → Firestore → `scheduledMessages` → Mesaj durumunu kontrol et

---

## 📞 Destek

Sorun yaşarsanız:
1. Firebase Console → Functions → Logs kontrol edin
2. `scheduledMessages` koleksiyonunda hataları kontrol edin
3. WhatsApp cihaz bağlantısını kontrol edin

---

## 🎉 Tamamlandı!

Artık sistem **tarayıcı kapalı olsa bile** arka planda mesaj gönderebilir! 🚀

