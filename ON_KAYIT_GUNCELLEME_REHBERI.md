# Ön Kayıt Güncelleme Rehberi

## 📋 Yapılan Değişiklikler

### 1. ✅ İsim Alanı Düzenlenebilir Yapıldı (kayit.html)
- Kayıt sayfasında **Ad Soyad** alanı artık düzenlenebilir
- Hem veliler hem de üyeler kendi isimlerini değiştirebilir
- `readonly` özelliği kaldırıldı

---

## 🔧 Elif Beren Karasu → Ahmet Tarık Gümüş Güncellemesi

### Yöntem 1: Admin Panelden Güncelleme (Önerilen)

1. **Admin Panele Giriş Yapın**
   - `admin.html` sayfasına gidin
   - Kullanıcı adı ve şifrenizle giriş yapın

2. **Kayıtlar Sekmesine Gidin**
   - Sol menüden "Kayıtlar" sekmesine tıklayın
   - Ön kayıt listesini göreceksiniz

3. **Kayıt Bulun**
   - Telefon numarası: **05054771397**
   - Mevcut isim: **Elif Beren Karasu**

4. **Düzenle**
   - Kayıt satırındaki **⋮** (üç nokta) menüsüne tıklayın
   - **"✏️ Ön Kayıt Düzenle"** seçeneğine tıklayın
   - İsim alanını **"Ahmet Tarık Gümüş"** olarak değiştirin
   - **Kaydet** butonuna tıklayın

5. **Onaylama**
   - Sayfa otomatik olarak yenilenecek
   - Değişiklik hem ön kayıt hem de üye kaydında güncellenecek

---

### Yöntem 2: Tarayıcı Konsolundan Güncelleme (Hızlı)

1. **Admin Panele Giriş Yapın**
   - `admin.html` sayfasına gidin ve giriş yapın

2. **Konsolu Açın**
   - **Chrome/Edge**: `F12` veya `Ctrl+Shift+J`
   - **Firefox**: `F12` veya `Ctrl+Shift+K`
   - **Safari**: `Cmd+Option+C`

3. **Script'i Çalıştırın**
   - `update_prereg_script.js` dosyasının içeriğini kopyalayın
   - Konsola yapıştırın ve `Enter` tuşuna basın
   - Script otomatik olarak:
     - Telefon numarasıyla kaydı bulur
     - İsmi günceller
     - İlişkili üye kaydını günceller

4. **Sayfayı Yenileyin**
   - `F5` veya `Ctrl+R` ile sayfayı yenileyin
   - Değişiklikleri göreceksiniz

---

### Yöntem 3: Firebase Konsolundan Güncelleme (Manuel)

1. **Firebase Console'a Gidin**
   - https://console.firebase.google.com/
   - Projenizi seçin: `uyekayit-5964b`

2. **Firestore Database'e Gidin**
   - Sol menüden "Firestore Database" seçin
   - "preRegistrations" koleksiyonunu bulun

3. **Kayıt Bulun**
   - Koleksiyonda arama yapın: `phone == "05054771397"`
   - VEYA manuel olarak listede bulun

4. **Düzenle**
   - Kayıt dokümanını açın
   - `studentName` veya `parentName` alanını bulun
   - **"Elif Beren Karasu"** → **"Ahmet Tarık Gümüş"** olarak değiştirin
   - **Update** butonuna tıklayın

5. **Members Koleksiyonunu da Güncelleyin**
   - "members" koleksiyonuna gidin
   - Aynı telefon numarasıyla ilişkili üye kaydını bulun
   - `Ad_Soyad` veya `Resit_Olmayan_Adi_Soyadi` alanını güncelleyin

---

## 📝 Notlar

### Çocuk Kaydı mı, Yetişkin Kaydı mı?

**Çocuk Kaydı:**
- `parentName`: Veli adı
- `studentName`: Öğrenci adı (Ahmet Tarık Gümüş)
- İki alan da dolu ve farklı

**Yetişkin Kaydı:**
- `parentName` ve `studentName` aynı
- Tek kişi kaydı

### Hangi Alanlar Güncellenir?

**preRegistrations koleksiyonu:**
- `studentName`: Öğrenci/Üye adı
- `parentName`: Veli adı (varsa)

**members koleksiyonu:**
- `Ad_Soyad`: Ana ad soyad (yetişkin için)
- `Resit_Olmayan_Adi_Soyadi`: Öğrenci adı (çocuk için)

---

## ✅ Değişiklik Kontrolü

Güncelleme sonrası kontrol edin:

1. **Admin Panelde:**
   - Kayıtlar sekmesinde yeni ismi görün
   - Üyeler sekmesinde yeni ismi görün

2. **Kayıt Sayfasında:**
   - Telefon numarasıyla giriş yapın
   - 3. adımda (Kişisel Bilgiler) yeni ismi göreceksiniz
   - İsim alanı artık düzenlenebilir olacak

3. **Ödeme Planında:**
   - Ödeme planı bölümünde yeni isim görünecek

---

## 🆘 Sorun Giderme

**"Kayıt bulunamadı" hatası:**
- Telefon numarasını kontrol edin (0 ile başlamalı)
- Farklı format deneyin: 05054771397, 5054771397, 905054771397

**"İzin hatası" alıyorsanız:**
- Admin hesabıyla giriş yaptığınızdan emin olun
- Yeterli yetkiye sahip olduğunuzu kontrol edin

**Değişiklik görünmüyorsa:**
- Tarayıcıyı tam olarak yenileyin (Ctrl+F5)
- Cache'i temizleyin
- Çıkış yapıp tekrar giriş yapın

---

## 📞 Destek

Sorun yaşarsanız:
- İletişim: 0362 363 00 64
- E-posta: y.aykut7455@gmail.com

