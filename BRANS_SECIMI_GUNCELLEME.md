# Branş Seçimi Güncelleme

## ✅ Yapılan İyileştirmeler

### 1. 🏢 Branşlar Artık Ayarlardan Geliyor
- Kayıt sayfasındaki branş seçimi artık **Admin Panel → Ayarlar → Branş Yönetimi**'ndeki branşlardan dinamik olarak yükleniyor
- Hardcoded "Tenis, Yüzme" seçenekleri kaldırıldı
- Her kulüp kendi branşlarını görecek

### 2. 🎯 Tek Branş Varsa Otomatik Seçili
- Eğer kulüpte sadece **1 aktif branş** varsa, otomatik olarak seçili geliyor
- Kullanıcı branş seçmek zorunda kalmıyor
- "Seçiniz..." seçeneği sadece 2+ branş varsa gösteriliyor

### 3. 💳 Branş Bazlı Ödeme Bilgileri
- Her branşın kendi IBAN ve ödeme bilgileri gösteriliyor
- Branş adı ve emoji ile gösterim yapılıyor
- Ödeme talimatları da branşa özel

## 📋 Kullanım Senaryoları

### Senaryo 1: Tek Branşlı Kulüp
```
Kulüp: Sadece Tenis branşı var
Kayıt Sayfası: 
  → Tenis otomatik seçili gelir
  → Kullanıcı sadece telefon girer
  → Tenis IBAN bilgileri gösterilir
```

### Senaryo 2: Çok Branşlı Kulüp
```
Kulüp: Tenis, Yüzme, Basketbol var
Kayıt Sayfası:
  → "Seçiniz..." gösterilir
  → Kullanıcı branş seçer
  → Seçilen branşın IBAN bilgileri gösterilir
```

### Senaryo 3: Pasif Branşlar
```
Kulüp: Tenis (aktif), Yüzme (pasif)
Kayıt Sayfası:
  → Sadece Tenis gösterilir
  → Otomatik seçili gelir
```

## 🔧 Teknik Detaylar

### Yeni Global Değişkenler
```javascript
let clubBranches = [];      // Kulübün branşları
let branchPayments = null;  // Branş bazlı ödeme bilgileri
```

### Yeni Fonksiyonlar
```javascript
populateBranchSelection()   // Branş dropdown'unu doldurur
```

### Güncellenmiş Fonksiyonlar
```javascript
loadContractTemplate()      // Artık branşları da yüklüyor
displayBranchIban()        // Branş adını ve emojisini gösteriyor
```

### Veri Akışı
1. Sayfa yüklendiğinde `loadContractTemplate()` çalışır
2. `club_{clubId}` dökümanından `branches` yüklenir
3. `populateBranchSelection()` çağrılır:
   - Aktif branşlar filtrelenir
   - Dropdown oluşturulur
   - Eğer 1 branş varsa otomatik seçilir
4. Kayıt tamamlanınca `displayBranchIban(branchId)` çalışır:
   - Branş bilgisi bulunur
   - IBAN/ödeme bilgileri gösterilir

## 🎨 Admin Panelde Ayarlama

### Branş Ekleme/Düzenleme
1. **Admin Panel** → **Ayarlar** → **Branş Yönetimi**
2. Branş ekle/düzenle/sil
3. Aktif/Pasif durumunu ayarla
4. İkon ve renk belirle

### Branş Ödeme Bilgileri
1. **Admin Panel** → **Ayarlar** → **Sözleşme Şablonu**
2. **"💳 Branş Bazlı Ödeme Bilgileri"** bölümüne git
3. Her branş için:
   - Hesap Sahibi / Banka Adı
   - IBAN Numarası
   - Ödeme Talimatları (isteğe bağlı)

## 📱 Kayıt Sayfası Görünümü

### Çok Branşlı Kulüp
```
┌─────────────────────────────────┐
│ Branş Seçimi *                  │
│ ┌─────────────────────────────┐ │
│ │ Seçiniz...                 ▼│ │
│ │ 🎾 Tenis                    │ │
│ │ 🏊 Yüzme                    │ │
│ │ 🏀 Basketbol                │ │
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
```

### Tek Branşlı Kulüp
```
┌─────────────────────────────────┐
│ Branş Seçimi *                  │
│ ┌─────────────────────────────┐ │
│ │ 🎾 Tenis                   ▼│ │ ← Otomatik Seçili
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
```

### Başarı Sayfası - Ödeme Bilgileri
```
┌─────────────────────────────────────┐
│ 🎾 Tenis - Ödeme Bilgileri         │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Hesap Sahibi: Ömer Bulut   [📋] │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ IBAN: TR00 0000...         [📋] │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Ödeme Talimatları:              │ │
│ │ Açıklama kısmına üye adınızı    │ │
│ │ yazınız                          │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

## ✅ Test Senaryoları

### Test 1: Tek Branş
- ✅ Branş otomatik seçili geliyor
- ✅ "Seçiniz..." gösterilmiyor
- ✅ Telefon girildiğinde direkt devam edilebiliyor

### Test 2: Çok Branş
- ✅ "Seçiniz..." gösteriliyor
- ✅ Tüm aktif branşlar listelenmiş
- ✅ Pasif branşlar gösterilmiyor

### Test 3: Branş Yönetimi
- ✅ Admin'de branş eklendiğinde kayıt sayfasında görünüyor
- ✅ Branş pasif edildiğinde kayıt sayfasından kaldırılıyor
- ✅ Branş ikon ve adı doğru gösteriliyor

### Test 4: Ödeme Bilgileri
- ✅ Her branşın kendi IBAN'ı gösteriliyor
- ✅ Branş adı ve emoji başlıkta görünüyor
- ✅ Ödeme talimatları doğru gösteriliyor
- ✅ Kopyala butonları çalışıyor

## 🎯 Avantajlar

1. **Esneklik**: Her kulüp kendi branşlarını kullanıyor
2. **Kullanıcı Deneyimi**: Tek branşta otomatik seçim yapılıyor
3. **Dinamik**: Admin panelden tüm ayarlar yapılabiliyor
4. **Görsel**: Her branşın kendi emoji ve renkli görünümü var
5. **Özelleştirilebilir**: Branş bazlı ödeme bilgileri

## 📝 Önemli Notlar

1. **Aktif/Pasif Durum**: Sadece aktif branşlar (`isActive !== false`) gösteriliyor
2. **Otomatik Seçim**: Tek branş varsa otomatik seçiliyor ve `attemptAdvanceFromStep1()` çağrılıyor
3. **Branş Bilgisi**: displayBranchIban'da branş ID'si ile branş adı eşleştiriliyor
4. **Geriye Dönük Uyumluluk**: Eski `ibanData` formatı da destekleniyor

## 🚀 Sonuç

Artık kayıt sayfası tamamen dinamik ve kullanıcı dostu! Her kulüp kendi branşlarını yönetiyor ve kullanıcılar en kolay şekilde kayıt olabiliyor. 🎉

