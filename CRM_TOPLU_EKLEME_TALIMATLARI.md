# 📥 CRM Toplu Müşteri Ekleme Talimatları

## 📋 Excel Şablonu Nasıl Hazırlanır?

### 1. Dosya Formatı
- **Excel (.xlsx)** veya **CSV (.csv)** formatında olabilir
- Şablon dosyası: `CRM_Toplu_Musteri_Ekleme_Sablonu.csv`
- UTF-8 kodlaması ile kaydedin (Türkçe karakterler için)

### 2. Sütun Yapısı (SIRALAMAYA UYUN!)

| Sıra | Sütun Adı | Zorunlu | Açıklama | Örnek Değerler |
|------|-----------|---------|----------|----------------|
| 1 | **Telefon** | ✅ Evet | 11 haneli telefon numarası (0 ile başlayan) | 05321234567 |
| 2 | **Ad Soyad** | ⚠️ Yetişkin için | Yetişkin müşteri için tam adı (Çocuk ise boş bırakın) | Ahmet Yılmaz |
| 3 | **Kaynak** | ✅ Evet | Müşteri nereden geldi? | Telefon / WhatsApp / Sosyal Medya / Referans / Web Sitesi / Diğer |
| 4 | **Branş** | ✅ Evet | Hangi branş için ilgileniyor? | Tenis / Voleybol / Fitness vb. |
| 5 | **Yaş Grubu** | ✅ Evet | Yetişkin mi, çocuk mu? | Yetişkin / Çocuk |
| 6 | **Etiket** | ❌ Hayır | CRM etiketi | Denemeye Geldi / Denemeye Gelecek / Aradı / Kayıt Olabilir vb. |
| 7 | **Veli Adı (Çocuk için)** | ⚠️ Çocuk için | Sadece çocuk müşteriler için veli adı | Ayşe Demir |
| 8 | **Çocuk Adı** | ⚠️ Çocuk için | Sadece çocuk müşteriler için çocuğun adı | Zeynep Demir |
| 9 | **Çocuk Yaşı** | ❌ Hayır | Çocuğun yaşı (sayı) | 8 |
| 10 | **Not** | ❌ Hayır | Ek açıklama/not | İlk görüşme yapıldı |

### 3. Önemli Kurallar

#### ✅ Telefon Numarası
- Mutlaka **11 hane** olmalı
- **0** ile başlamalı
- Örnek: `05321234567`
- Boşluk, tire, parantez kullanmayın

#### ✅ Kaynak Değerleri (Seçenekler)
- `Telefon`
- `WhatsApp`
- `Sosyal Medya`
- `Referans`
- `Web Sitesi`
- `Diğer`

#### ✅ Yaş Grubu (Seçenekler)
- `Yetişkin` - Kendi adına kayıt olan müşteri → **"Ad Soyad"** dolu, **"Veli Adı"** ve **"Çocuk Adı"** boş
- `Çocuk` - Velisi kayıt oluşturan müşteri → **"Ad Soyad"** boş, **"Veli Adı"** ve **"Çocuk Adı"** dolu

#### ✅ Branş
- Sisteminizde tanımlı branş adını yazın
- Örnek: `Tenis`, `Voleybol`, `Basketbol`
- Büyük/küçük harf farkı gözetmez

#### ✅ Etiket (İsteğe Bağlı)
- Sisteminizde tanımlı etiket adını yazın
- Boş bırakılabilir
- Örnek: `Denemeye Geldi`, `Aradı`, `Kayıt Olabilir`

#### ✅ Çocuk Müşteriler İçin Özel Alanlar
- **Veli Adı:** Çocuğun velisinin tam adı (Örnek: `Ayşe Demir`)
- **Çocuk Adı:** Çocuğun adı (Örnek: `Zeynep Demir`)
- **Çocuk Yaşı:** Çocuğun yaşı, sadece rakam (Örnek: `8`)
- ⚠️ Bu alanlar sadece **Yaş Grubu** = **Çocuk** olan satırlar için doldurulmalıdır
- ⚠️ Yetişkin müşteriler için bu alanları boş bırakın

#### ✅ Not (İsteğe Bağlı)
- Müşteri hakkında ek bilgi
- Boş bırakılabilir
- Örnek: `Cumartesi deneme dersi talep etti`

### 4. Örnek Satırlar

```csv
Telefon,Ad Soyad,Kaynak,Branş,Yaş Grubu,Etiket,Veli Adı (Çocuk için),Çocuk Adı,Çocuk Yaşı,Not
05321234567,Ahmet Yılmaz,Telefon,Tenis,Yetişkin,Denemeye Geldi,,,İlk görüşme yapıldı
05439876543,,WhatsApp,Tenis,Çocuk,Denemeye Gelecek,Ayşe Demir,Zeynep Demir,8,Cumartesi deneme dersi
05551234567,Mehmet Kaya,Sosyal Medya,Voleybol,Yetişkin,Aradı,,,Fiyat bilgisi verildi
05449876543,,Telefon,Tenis,Çocuk,Kayıt Olabilir,Fatma Şahin,Ali Şahin,10,2 çocuk var
05505123456,Hakan Yıldız,Referans,Tenis,Yetişkin,Denemeye Geldi,,,Başlangıç seviyesi
```

**Dikkat:** 
- Satır 2 ve 4 **Yetişkin** → "Ad Soyad" dolu, çocuk alanları boş
- Satır 3 ve 5 **Çocuk** → "Ad Soyad" boş, "Veli Adı", "Çocuk Adı" dolu

### 5. Excel'de Dosya Kaydetme

#### Microsoft Excel:
1. Dosyayı açın
2. **Dosya** → **Farklı Kaydet**
3. **Dosya Türü:** "CSV UTF-8 (Virgülle ayrılmış) (*.csv)" seçin
4. Kaydedin

#### Google Sheets:
1. Dosyayı açın
2. **Dosya** → **İndir** → **Virgülle ayrılmış değerler (.csv)**

### 6. Sık Yapılan Hatalar

❌ **YANLIŞ:**
```
0532 123 45 67    → Boşluklu telefon
532 123 45 67     → 0 ile başlamıyor
(0532) 123-4567   → Parantez ve tire var
```

✅ **DOĞRU:**
```
05321234567       → Temiz, 11 haneli
```

❌ **YANLIŞ:**
```
Kaynak: telefon   → Küçük harf, sisteme uymuyor
Yaş Grubu: Adult  → İngilizce
```

✅ **DOĞRU:**
```
Kaynak: Telefon
Yaş Grubu: Yetişkin
```

❌ **YANLIŞ (Çocuk Müşteri):**
```
Telefon,Ad Soyad,Kaynak,Branş,Yaş Grubu,Etiket,Veli Adı,Çocuk Adı,Çocuk Yaşı,Not
05321234567,Ahmet Yılmaz,Telefon,Tenis,Çocuk,,,,Çocuk müşteri   → Veli/çocuk adı yok!
```

✅ **DOĞRU (Çocuk Müşteri):**
```
Telefon,Ad Soyad,Kaynak,Branş,Yaş Grubu,Etiket,Veli Adı,Çocuk Adı,Çocuk Yaşı,Not
05321234567,,Telefon,Tenis,Çocuk,,Ahmet Yılmaz,Mehmet Yılmaz,9,Çocuk müşteri
```

### 7. Import Süreci

1. **Admin Panel'e** giriş yapın
2. **CRM Dashboard** sayfasını açın
3. **"📥 Toplu İçe Aktar"** butonuna tıklayın
4. **Excel/CSV dosyanızı** seçin
5. **Önizleme** ekranında kontrol edin
6. **"✅ Tümünü Ekle"** butonuna tıklayın

### 8. Kontroller

Sistem otomatik olarak şunları kontrol eder:

✅ Telefon numarası geçerli mi?
✅ Zorunlu alanlar dolu mu?
✅ Bu telefon numarası zaten kayıtlı mı?
✅ Branş sistemde tanımlı mı?
✅ Kaynak ve yaş grubu değerleri geçerli mi?
✅ **Çocuk müşteriler için:** Veli Adı ve Çocuk Adı dolu mu?
✅ **Yetişkin müşteriler için:** Ad Soyad dolu mu?

### 9. Sorun Giderme

**Soru:** "Türkçe karakterler bozuk görünüyor"
**Cevap:** Dosyayı **UTF-8** kodlaması ile kaydedin.

**Soru:** "Bazı müşteriler eklenmedi"
**Cevap:** Hata raporunu kontrol edin. Muhtemelen:
- Telefon numarası zaten kayıtlı
- Zorunlu alan boş
- Geçersiz format

**Soru:** "Branş bulunamadı hatası"
**Cevap:** Excel'deki branş adı sisteminizde tanımlı branşlardan biri olmalı.

---

## 📞 Destek

Sorun yaşarsanız:
1. Hata mesajını kaydedin
2. Örnek satırı paylaşın
3. Sistem yöneticinize bildirin

---

**Son Güncelleme:** 26 Ekim 2025

