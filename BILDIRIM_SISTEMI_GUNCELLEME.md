# 🔔 BİLDİRİM SİSTEMİ GÜNCELLEMESİ - STACK (YIĞIN) SİSTEMİ

## ❌ Eski Sorun
Cevapsız çağrı ve WhatsApp bildirimleri aynı anda geldiğinde **üst üste biniyordu**.

**Örnek:**
```
┌─────────────────────────┐
│ 📵 1 CEVAPSIZ ÇAĞRI!   │ ← Üstte kaldı
└─────────────────────────┘
┌─────────────────────────┐
│ 💬 Ahmet Yılmaz        │ ← Alta geçti, birbirini kapatıyor
│    Merhaba hocam...    │
└─────────────────────────┘
```

## ✅ Yeni Çözüm - STACK (YIĞIN) SİSTEMİ

Bildirimler artık **üst üste gelmek yerine alta sırayla diziliyor**:

```
┌─────────────────────────┐
│ 📵 1 CEVAPSIZ ÇAĞRI!   │ ← İlk bildirim (top: 20px)
└─────────────────────────┘
       ↓ 10px boşluk
┌─────────────────────────┐
│ 💬 Ahmet Yılmaz        │ ← İkinci bildirim (top: 90px)
│    Merhaba hocam...    │
└─────────────────────────┘
       ↓ 10px boşluk
┌─────────────────────────┐
│ 💬 Mehmet Demir        │ ← Üçüncü bildirim (top: 180px)
│    Nasılsınız...       │
└─────────────────────────┘
```

### 1. Global Bildirim Stack (Yığın)
```javascript
// ✅ GLOBAL BİLDİRİM STACK - Tüm bildirimler için
let notificationStack = [];

// ✅ Bildirimi stack'e ekle ve konumunu güncelle
function addNotificationToStack(alertDiv) {
    // Stack'e ekle
    notificationStack.push(alertDiv);
    
    // DOM'a ekle
    document.body.appendChild(alertDiv);
    
    // Tüm bildirimlerin konumunu güncelle (alta doğru sırala)
    updateNotificationPositions();
    
    return alertDiv;
}

// ✅ Bildirim stack'ten çıkarıldığında konumları güncelle
function removeNotificationFromStack(alertDiv) {
    const index = notificationStack.indexOf(alertDiv);
    if (index > -1) {
        notificationStack.splice(index, 1);
        updateNotificationPositions();
    }
}

// ✅ Tüm bildirimlerin konumunu güncelle (üstten alta doğru)
function updateNotificationPositions() {
    let topOffset = 20; // İlk bildirim 20px yukarıdan
    
    notificationStack.forEach((notification, index) => {
        if (notification && notification.parentElement) {
            notification.style.top = topOffset + 'px';
            notification.style.transition = 'top 0.3s ease-out, opacity 0.3s';
            
            // Bir sonraki bildirim için offset hesapla
            topOffset += notification.offsetHeight + 10; // 10px boşluk
        }
    });
}
```

### 2. Otomatik Konum Hesaplama

Her bildirim eklendiğinde veya kaldırıldığında, tüm bildirimlerin konumu **otomatik olarak yeniden hesaplanır**:

1. **İlk bildirim:** `top: 20px`
2. **İkinci bildirim:** `top: 20px + ilkBildirimYüksekliği + 10px`
3. **Üçüncü bildirim:** `top: öncekiTop + ikinciBildirimYüksekliği + 10px`

### 3. Smooth Animations (Yumuşak Geçişler)

Bildirim kapandığında diğerleri **yumuşak bir şekilde yukarı kayar**:

```css
transition: top 0.3s ease-out, opacity 0.3s;
```

## 🎯 Nasıl Çalışıyor?

### Senaryo 1: Bildirimler Sırayla Geliyor

1. **Cevapsız çağrı gelir** → Stack'e eklenir
   - `notificationStack = [cevapsızÇağrı]`
   - Pozisyon: `top: 20px`

2. **WhatsApp mesajı gelir** → Stack'e eklenir
   - `notificationStack = [cevapsızÇağrı, whatsapp1]`
   - Pozisyonlar güncellenir:
     - cevapsızÇağrı: `top: 20px`
     - whatsapp1: `top: 90px` (cevapsız çağrı yüksekliği 60px + 10px boşluk)

3. **İkinci WhatsApp mesajı gelir** → Stack'e eklenir
   - `notificationStack = [cevapsızÇağrı, whatsapp1, whatsapp2]`
   - Pozisyonlar:
     - cevapsızÇağrı: `top: 20px`
     - whatsapp1: `top: 90px`
     - whatsapp2: `top: 160px`

### Senaryo 2: Ortadaki Bildirim Kapatılıyor

1. **Başlangıç durumu:**
   ```
   [cevapsızÇağrı (20px), whatsapp1 (90px), whatsapp2 (160px)]
   ```

2. **Kullanıcı `whatsapp1`'i kapatır:**
   - `removeNotificationFromStack(whatsapp1)` çağrılır
   - Stack'ten çıkarılır: `notificationStack = [cevapsızÇağrı, whatsapp2]`
   - Pozisyonlar yeniden hesaplanır:
     - cevapsızÇağrı: `top: 20px` (değişmedi)
     - whatsapp2: `top: 90px` ← **YUKARI KAYDI** (160px → 90px)

3. **Yumuşak animasyon:**
   - `whatsapp2` 0.3 saniyede yukarı kayar (`transition: top 0.3s ease-out`)

## 🧪 Test Senaryoları

### Test 1: Çoklu Bildirim
1. Telefondan ara + kapat (cevapsız çağrı)
2. Hızlıca 3 WhatsApp mesajı gönder
3. **Beklenen:** 
   - 4 bildirim alta doğru sırayla dizilmeli
   - Üst üste gelmemeli
   - Her biri 10px boşlukla ayrılmalı

### Test 2: Ortadan Kapatma
1. 3 bildirim oluştur
2. Ortadakini X ile kapat
3. **Beklenen:**
   - Alttaki bildirim yukarı kaymalı (smooth animation)
   - Stack düzgün çalışmalı

### Test 3: Otomatik Kapanma
1. 2 bildirim oluştur
2. İlki 12 saniye sonra otomatik kapansın
3. **Beklenen:**
   - İkinci bildirim yukarı kaymalı
   - `top` değeri güncellenip `20px` olmalı

### Test 4: Tıklama
1. 2 bildirim oluştur
2. Birine tıkla (ilgili sayfaya gitmeli)
3. **Beklenen:**
   - Tıklanan bildirim kapanmalı
   - Diğeri yukarı kaymalı

## 📊 Değişiklik Özeti

### Eklenen Fonksiyonlar:
1. ✅ `addNotificationToStack(alertDiv)` - Bildirimi stack'e ekle ve pozisyonları güncelle
2. ✅ `removeNotificationFromStack(alertDiv)` - Bildirimi stack'ten çıkar ve pozisyonları güncelle
3. ✅ `updateNotificationPositions()` - Tüm bildirimlerin konumunu hesapla

### Değiştirilen Fonksiyonlar:
1. ✅ `showMissedCallNotification()` - Stack sistemi kullanıyor
2. ✅ `showWhatsAppMessageNotification()` - Stack sistemi kullanıyor

### Global Değişkenler:
1. ✅ `notificationStack = []` - Aktif bildirimlerin array'i

### CSS Değişiklikleri:
- ❌ `top: 20px` (sabit) → KALDIRILDI
- ❌ `top: 80px` (sabit) → KALDIRILDI
- ✅ `top: dinamik` → Stack tarafından hesaplanıyor (JavaScript)

## 🎨 Bildirim Konumları (Dinamik)

### İlk Bildirim:
```css
position: fixed;
top: 20px;  /* JavaScript tarafından ayarlanıyor */
right: 20px;
```

### İkinci Bildirim:
```css
position: fixed;
top: 90px;  /* İlk bildirim yüksekliği (60px) + boşluk (10px) + başlangıç (20px) */
right: 20px;
```

### Üçüncü Bildirim:
```css
position: fixed;
top: 160px;  /* İkinci top (90px) + ikinci yükseklik (60px) + boşluk (10px) */
right: 20px;
```

## ✅ Başarı Kriterleri

Tümü başarılı olmalı:
- ✅ Bildirimler alta doğru sırayla diziliyor
- ✅ Her bildirim arasında 10px boşluk var
- ✅ Bildirim kapandığında diğerleri yukarı kayıyor (smooth)
- ✅ Manuel X butonuyla kapatılabiliyor
- ✅ Otomatik timeout ile kapanıyor
- ✅ Bildirimlere tıklandığında ilgili sayfaya gidiyor
- ✅ Browser notification (masaüstü bildirim) hala çalışıyor
- ✅ Maksimum 10 bildirim olsa bile ekrandan taşmıyor

## 🔍 Debug Komutları

### Stack'i kontrol et:
```javascript
console.log('Aktif bildirimler:', notificationStack.length);
notificationStack.forEach((n, i) => {
    console.log(`${i+1}. bildirim - top: ${n.style.top}`);
});
```

### Manuel bildirim ekle (test):
```javascript
// Cevapsız çağrı
await showMissedCallNotification(3);

// WhatsApp
await showWhatsAppMessageNotification(1, 'Test User', 'Test mesajı');

// 5 bildirim arka arkaya
for (let i = 0; i < 5; i++) {
    await showWhatsAppMessageNotification(1, `Kullanıcı ${i+1}`, `Mesaj ${i+1}`);
    await new Promise(r => setTimeout(r, 500)); // 500ms bekle
}
```

### Stack'i temizle (tüm bildirimleri kapat):
```javascript
notificationStack.forEach(n => n.remove());
notificationStack = [];
```

### Pozisyonları yeniden hesapla:
```javascript
updateNotificationPositions();
```

## 🎬 Animasyon Detayları

### Yeni Bildirim Geldiğinde:
1. `addNotificationToStack()` çağrılır
2. Bildirim DOM'a eklenir
3. `updateNotificationPositions()` tüm bildirimlerin `top` değerini günceller
4. CSS `transition: top 0.3s ease-out` sayesinde yumuşak kayar

### Bildirim Kapandığında:
1. `removeNotificationFromStack()` çağrılır
2. Bildirim array'den çıkarılır
3. `updateNotificationPositions()` kalan bildirimlerin `top` değerini günceller
4. Alttaki bildirimler yukarı kayar (0.3 saniye animasyon)

---

**Sonuç:** Artık bildirimler **stack (yığın)** sistemiyle yönetiliyor. Üst üste gelmek yerine alta doğru sırayla diziliyor ve kapandığında diğerleri yukarı kayıyor! 🎉
