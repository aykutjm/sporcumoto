# 📄 PDF Sözleşme Sayfalama - Kullanım Kılavuzu

## 🎯 Genel Bakış

PDF sözleşme oluşturma sistemi, admin panelde girilen sözleşme metnini otomatik olarak sayfalara böler ve kullanıcıların indirmesi için profesyonel bir PDF belgesi oluşturur.

---

## 🔧 İki Sayfalama Yöntemi

### Yöntem 1: Manuel Sayfalama (`<hr>` ile) ⭐ ÖNERİLEN

Admin panelde sözleşme metnine `<hr>` etiketi ekleyerek sayfa sonlarını kendiniz belirleyebilirsiniz.

#### Örnek Kullanım:

```html
<h4>1-) TARAFLAR</h4>
<p>Kulüp adı: Atakum Tenis Kulübü</p>
<p>Adres: Derecik Mahallesi...</p>

<hr>  <!-- ✅ YENİ SAYFA BAŞLAR -->

<h4>2-) KONU</h4>
<p>İşbu sözleşme, spor eğitimi hizmeti...</p>
```

#### ✅ Avantajları:
- Sayfa sonlarını tam olarak kontrol edersiniz
- Maddelerin ortasında bölünme olmaz
- Profesyonel görünüm

#### ⚠️ Dikkat:
- **10'dan fazla `<hr>` kullanmayın!** (Her `<hr>` = yeni sayfa)
- Eğer çok fazla `<hr>` eklerseniz, console'da uyarı görürsünüz:
  ```
  ⚠️ Çok fazla <hr> tag'i var (12). PDF bozulabilir.
  ```

---

### Yöntem 2: Otomatik Sayfalama

Eğer `<hr>` kullanmazsanız, sistem içeriği otomatik olarak dengeli sayfalara böler.

#### Nasıl Çalışır:
1. Her sayfa **maksimum 4000 karakter** içerir
2. **Minimum 2000 karakter** olana kadar sayfa bölünmez
3. **Tablolar ve listeler** asla bölünmez (bütün olarak bir sayfada kalır)
4. **Başlıklar** mümkün olduğunca içerikleriyle aynı sayfada tutulur

#### Console Çıktısı:
```
📄 Akıllı sayfalama başlıyor: {
    totalElements: 45,
    totalChars: 14380,
    maxCharsPerPage: 4000
}
📄 Sayfalama tamamlandı: 4 sayfa oluşturuldu
```

---

## 📐 Sayfa Yüksekliği Kontrolü

Sistem her sayfanın yüksekliğini dinamik olarak hesaplar.

### Normal Durum (≤ 1200px):
```
📄 Sayfa 1/4 render ediliyor...
   İçerik yüksekliği: 950px ✅
✅ Sayfa 1 eklendi (595x842)
```

### Yüksek Sayfa (> 1200px):
```
⚠️ Sayfa 2 çok yüksek (1580px > 1200px)! PDF'de kesilme olabilir.
💡 Admin panelde bu bölüme <hr> ekleyerek sayfaları manuel bölebilirsiniz.
📄 Sayfa 2 çok yüksek (1095px), 2 sayfaya bölünüyor...
   ✅ Alt-sayfa 1/2 eklendi
   ✅ Alt-sayfa 2/2 eklendi
```

**Çözüm:** Admin panelde o bölüme `<hr>` ekleyin.

---

## 🎨 PDF Stili ve Format

### Font Ayarları:
- **Font Ailesi:** Segoe UI, Helvetica Neue, Arial
- **Ana Metin:** 11px, satır aralığı 1.6
- **Başlıklar:** 
  - H1: 20px (ana başlık)
  - H4: 13px (alt başlıklar)
  - H3, H5: 12px

### Renkler:
- **Başlık:** #667eea (mor-mavi)
- **Ana Metin:** #1f2937 (koyu gri)
- **Tablolar:** #f3f4f6 (açık gri arka plan)

### Tablolar:
```css
- Kenarlık: 1px solid #d1d5db
- Padding: 8px 6px
- Font: 9.5px (daha küçük)
- Başlık arka plan: #f3f4f6
```

---

## 📝 Örnek Sözleşme Şablonu

```html
<h3>ÜYELİK SÖZLEŞMESİ</h3>

<h4>1-) TARAFLAR</h4>

<p><strong>A-KULÜP</strong></p>
<p>Adı-Soyadı: Aykut YILDIRIM</p>
<p>Ünvanı: Atakum Tenis Kulübü</p>
<p>Adres: Derecik Mahallesi 1444. Sokak No:1 İlkadım/Samsun</p>
<p>Vergi No: 9540639540</p>
<p>Telefon: 0362 363 00 64</p>
<p>E-mail: y.aykut7455@gmail.com</p>
<p>Bu sözleşmede bundan sonra "EĞİTMEN/KULÜP" olarak anılacaktır.</p>

<p><strong>B-ÜYE/VELİ</strong></p>
<p>Adı-Soyadı: {UYE_AD_SOYAD}</p>
<p>Doğum Tarihi: {UYE_DOGUM_TARIHI}</p>
<p>Adres: {UYE_ADRES}</p>
<p>TCKN: {UYE_TCKN}</p>
<p>Telefon: {UYE_TELEFON}</p>
<p>Bu sözleşmede bundan sonra "ÜYE/VELİ" olarak anılacaktır.</p>

{Ogrenci_Bilgileri}

<hr>  <!-- ✅ YENİ SAYFA -->

<h4>2-) KONU</h4>
<p>İşbu sözleşme, Eğitmen tarafından kendisinden talep edilen her türlü bilgiyi eksiksiz ve doğru olarak Eğitmene vermeyi kabul etmektedir...</p>

<hr>  <!-- ✅ YENİ SAYFA -->

<h4>3-) AİDAT PLANI</h4>
{AIDAT_TAKVIMI}

<hr>  <!-- ✅ YENİ SAYFA -->

<h4>4-) GENEL HÜKÜMLER</h4>
<p>Üye/Veli, işbu sözleşmeyi onaylaması sırasında Eğitmene bildirdiği bilgilerin doğruluğundan...</p>
```

---

## 🔍 Dinamik Alanlar (Placeholder'lar)

Sözleşmede kullanılabilecek dinamik alanlar:

| Placeholder | Açıklama | Örnek |
|------------|----------|-------|
| `{UYE_AD_SOYAD}` veya `{Ad_Soyad}` | Veli/üye adı | Mehmet Yılmaz |
| `{UYE_TCKN}` veya `{TC_Kimlik_No}` | TC kimlik no | 12345678901 |
| `{UYE_TELEFON}` veya `{Telefon}` | Telefon | 0532 123 4567 |
| `{UYE_ADRES}` veya `{Adres}` | Adres | Derecik Mah. ... |
| `{UYE_DOGUM_TARIHI}` veya `{Dogum_Tarihi}` | Doğum tarihi | 01.01.1990 |
| `{Veli_2_Adi_Soyadi}` | İkinci veli | Ayşe Yılmaz |
| `{Telefon_2}` | İkinci telefon | 0533 987 6543 |
| `{Ogrenci_Bilgileri}` | Öğrenci detayları | (Otomatik tablo) |
| `{AIDAT_TAKVIMI}` | Ödeme planı | (Otomatik tablo) |
| `{TARIH}` | Sözleşme tarihi | 09.11.2025 |
| `{BRANS}` | Branş adı | Tenis |

---

## 🚀 Admin Panel Kullanımı

### 1. Sözleşme Şablonunu Düzenleme

1. **Admin Panel** → **Ayarlar** sekmesi
2. **"📄 Sözleşme Şablonu (HTML)"** bölümünü bulun
3. Sözleşmenizi HTML formatında yazın
4. **`<hr>` ekleyerek sayfa sonlarını belirleyin**
5. **Kaydet** butonuna tıklayın

### 2. Önizleme

Kayıt sayfasını açarak sözleşmeyi önizleyebilirsiniz:
```
http://localhost/uyeyeni/kayit.html?club=atakumteniskulubu
```

### 3. Test Kaydı

1. Telefon numaranızla kayıt yapın
2. Formu doldurun
3. İmza atın
4. PDF'i indirin
5. **Kontrol Listesi:**
   - [ ] Tüm sayfalar eksiksiz mi?
   - [ ] Metin düzgün mü?
   - [ ] Tablolar düzgün mü?
   - [ ] Türkçe karakterler doğru mu?
   - [ ] İmza son sayfada mı?
   - [ ] Sayfa numaraları doğru mu?

---

## ⚙️ İleri Düzey Ayarlar

### Sayfa Kapasitesini Değiştirme

Eğer sayfaların daha kısa/uzun olmasını istiyorsanız, `kayit.html` dosyasında:

```javascript
const maxCharsPerPage = 4000; // Varsayılan
const minCharsPerPage = 2000; // Varsayılan
```

**Öneriler:**
- Çok uzun sözleşmeler için: `maxCharsPerPage = 3500`
- Kısa sözleşmeler için: `maxCharsPerPage = 5000`

### PDF Kalitesini Değiştirme

```javascript
const imgData = pageCanvas.toDataURL('image/jpeg', 0.95); // 0.95 = %95 kalite
```

- **Daha yüksek kalite:** `0.98` (dosya boyutu artar)
- **Daha düşük kalite:** `0.85` (dosya boyutu azalır)

---

## 🐛 Sık Karşılaşılan Sorunlar

### Sorun 1: PDF'te Son Sayfa Eksik

**Neden:** Sayfa çok uzun, sisteme sığmıyor

**Çözüm:**
1. Admin panelde o bölüme `<hr>` ekleyin
2. Veya `maxCharsPerPage`'i azaltın (örn: 3500)

**Console Log:**
```
⚠️ Sayfa 3 çok yüksek (1850px > 1200px)!
💡 Admin panelde bu bölüme <hr> ekleyerek sayfaları manuel bölebilirsiniz.
```

---

### Sorun 2: Tablo Bölünüyor

**Neden:** Tablo çok uzun

**Çözüm:**
1. Tablodan hemen önce `<hr>` ekleyin
2. Tabloyu birden fazla küçük tabloya bölün

**Örnek:**
```html
<p>Ödeme planı aşağıdaki gibidir:</p>
<hr>  <!-- ✅ Tabloyu yeni sayfaya taşı -->
<table>
  ...
</table>
```

---

### Sorun 3: Çok Fazla Sayfa

**Neden:** Her madde için `<hr>` eklenmiş

**Çözüm:**
- Sadece ana bölümler arasına `<hr>` ekleyin
- Örnek: Madde 1-5 → 1. sayfa, Madde 6-10 → 2. sayfa

---

### Sorun 4: Türkçe Karakterler Bozuk

**Neden:** Font yüklenemedi

**Çözüm:**
- Console'da hata var mı kontrol edin
- Tarayıcı önbelleğini temizleyin (Ctrl+F5)
- Sistem otomatik düzeltir: `letterRendering: true`

---

## 📊 Performans İpuçları

### ✅ İyi Pratikler:
- ✅ 10 sayfadan kısa sözleşmeler oluşturun
- ✅ Manuel `<hr>` kullanın (daha hızlı render)
- ✅ Büyük tabloları küçük parçalara bölün
- ✅ Gereksiz boşlukları temizleyin

### ❌ Kaçınılması Gerekenler:
- ❌ 20+ sayfalık uzun sözleşmeler
- ❌ 10'dan fazla `<hr>` kullanımı
- ❌ Çok büyük tablolar (50+ satır)
- ❌ Gereksiz HTML elementleri

---

## 📞 Destek

Sorun yaşıyorsanız, console log'larını kontrol edin:

```javascript
// Chrome: F12 → Console sekmesi
// Aranacak anahtar kelimeler:
// - ❌ (hata)
// - ⚠️ (uyarı)
// - 📄 (sayfalama)
```

**Örnek Hata:**
```
❌ PDF oluşturma hatası: Failed to load image
```

**Örnek Uyarı:**
```
⚠️ Sayfa 2 çok yüksek (1580px > 1200px)!
💡 Admin panelde bu bölüme <hr> ekleyerek sayfaları manuel bölebilirsiniz.
```

---

## ✅ Özet

1. **Manuel sayfalama (`<hr>`)** kullanın = En iyi sonuç
2. **4000 karakter/sayfa** kuralı = Güvenli
3. **Console log'ları takip edin** = Sorunları erken tespit
4. **Test edin** = Canlıya geçmeden önce mutlaka kontrol

**Başarılı bir PDF için:** İyi yapılandırılmış HTML + Manuel `<hr>` + Test

---

**Hazırlayan:** AI Asistan  
**Tarih:** 2025-11-09  
**Versiyon:** 2.0 (Eksik Sayfa Düzeltmesi)




















