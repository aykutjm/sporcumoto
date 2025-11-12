# Sözleşme Placeholder Düzeltmesi

## ❌ Problem
Kayıt sayfasındaki sözleşme gösterilirken placeholder'lar (örn: `{KULUP_ADI}`, `{UYE_AD_SOYAD}`, `{BRANS}`) değiştirilmiyordu. Sözleşmede bu değişkenler olduğu gibi görünüyordu.

## ✅ Çözüm
`populateContractText()` fonksiyonu güncellenerek tüm placeholder'ların doğru verilerle değiştirilmesi sağlandı.

## 📋 Desteklenen Tüm Placeholder'lar

### 🏢 Kulüp Bilgileri
| Placeholder | Açıklama | Örnek |
|------------|----------|-------|
| `{KULUP_ADI}` | Kulüp resmi adı | Atakum Tenis Kulübü |
| `{YETKILI_ADI}` | Yetkili kişi adı | Ömer Bulut |
| `{KULUP_ADRES}` | Kulüp adresi | Derecik Mah. ... |
| `{VERGI_NO}` | Vergi numarası | 1234567890 |
| `{KULUP_TELEFON}` | Kulüp telefonu | 0362 363 00 64 |
| `{KULUP_EMAIL}` | Kulüp e-posta | info@atakumtenis.com |

### 👤 Üye/Veli Bilgileri
| Placeholder | Alternatif | Açıklama | Örnek |
|------------|-----------|----------|-------|
| `{UYE_AD_SOYAD}` | `{Ad_Soyad}` | Veli/Üye adı soyadı | Mehmet Yılmaz |
| `{UYE_TCKN}` | `{TC_Kimlik_No}` | TC Kimlik No | 12345678901 |
| `{UYE_TELEFON}` | `{Telefon}` | Telefon numarası | 0532 123 4567 |
| `{UYE_ADRES}` | `{Adres}` | Adres | Atatürk Mah. ... |
| `{UYE_DOGUM_TARIHI}` | `{Dogum_Tarihi}` | Doğum tarihi | 15.05.1985 |
| `{Veli_2_Adi_Soyadi}` | - | İkinci veli adı | Ayşe Yılmaz |
| `{Telefon_2}` | - | İkinci veli telefonu | 0533 987 6543 |

### 👶 Öğrenci Bilgileri (Çocuk Kayıtlarında)
| Placeholder | Alternatif | Açıklama |
|------------|-----------|----------|
| `{OGRENCI_BILGILERI}` | `{Ogrenci_Bilgileri}` veya `{ogrenci_bilgileri}` | Tüm öğrenci bilgileri (HTML tablo) |

**Not:** Öğrenci bilgileri otomatik olarak HTML formatında tablo şeklinde oluşturulur:
```html
<div style="margin: 15px 0;">
  <h4>👶 Öğrenci Bilgileri</h4>
  <p><strong>Öğrenci 1:</strong> Ali Yılmaz<br>
     <span style="margin-left: 20px;">Doğum Tarihi: 10.03.2015</span></p>
  <p><strong>Öğrenci 2:</strong> Zeynep Yılmaz<br>
     <span style="margin-left: 20px;">Doğum Tarihi: 22.07.2017</span></p>
</div>
```

### 🏆 Branş ve Tarih Bilgileri
| Placeholder | Açıklama | Örnek |
|------------|----------|-------|
| `{BRANS}` | Seçilen branş adı | Tenis |
| `{TARIH}` | Sözleşme tarihi (bugün) | 09.11.2025 |

### 💰 Aidat Bilgileri
| Placeholder | Alternatif | Açıklama |
|------------|-----------|----------|
| `{AIDAT_TAKVIMI}` | `{aidat_takvimi}` | Aidat ödeme planı (HTML tablo) |

**Not:** Aidat takvimi otomatik olarak HTML tablo formatında oluşturulur:
```html
<table style="width: 100%; border-collapse: collapse; margin: 15px 0;">
  <thead>
    <tr>
      <th>Aidat No</th>
      <th>Dönem</th>
      <th>Ders Sayısı</th>
      <th>Son Ödeme</th>
      <th>Tutar</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>1. Aidat</td>
      <td>01.12.2025 - 31.12.2025</td>
      <td>8 Ders</td>
      <td>05.12.2025</td>
      <td><strong>1500₺</strong></td>
    </tr>
    ...
  </tbody>
</table>
```

## 🎨 Admin Panelde Kullanım

Admin panelde sözleşme şablonunu düzenlerken bu placeholder'ları kullanabilirsiniz:

```html
<h3>ÜYELİK SÖZLEŞMESİ</h3>

<p>İşbu sözleşme {TARIH} tarihinde {KULUP_ADI} ile {UYE_AD_SOYAD} 
(T.C. Kimlik No: {UYE_TCKN}) arasında aşağıdaki şartlarda akdedilmiştir.</p>

<h4>1. TARAFLAR</h4>
<p><strong>Kulüp:</strong> {KULUP_ADI}<br>
<strong>Yetkili:</strong> {YETKILI_ADI}<br>
<strong>Adres:</strong> {KULUP_ADRES}<br>
<strong>Telefon:</strong> {KULUP_TELEFON}<br>
<strong>E-posta:</strong> {KULUP_EMAIL}</p>

<p><strong>Üye/Veli:</strong> {UYE_AD_SOYAD}<br>
<strong>T.C. Kimlik No:</strong> {UYE_TCKN}<br>
<strong>Telefon:</strong> {UYE_TELEFON}<br>
<strong>Adres:</strong> {UYE_ADRES}<br>
<strong>Doğum Tarihi:</strong> {UYE_DOGUM_TARIHI}</p>

{OGRENCI_BILGILERI}

<h4>2. BRANŞ VE AİDAT</h4>
<p>Üye, {BRANS} branşında kayıt olmuştur.</p>

<h4>3. ÖDEME PLANI</h4>
{AIDAT_TAKVIMI}

<p>Sözleşme tarihi: {TARIH}</p>
```

## 🔧 Teknik Detaylar

### Değişiklik Yapılan Fonksiyon
`populateContractText()` fonksiyonu güncellenmiştir (`uyeyeni/kayit.html` dosyası, satır ~1360-1417).

### Eklenen Özellikler
1. **Kulüp bilgilerinin değiştirilmesi**: `clubData` kullanılarak kulüp bilgileri placeholder'larına yazılıyor
2. **Branş bilgisinin bulunması**: `clubBranches` dizisinden seçilen branşın adı alınıyor
3. **Aidat takvimi oluşturma**: `paymentSchedule` dizisi HTML tablo formatına dönüştürülüyor
4. **Tarih formatlama**: Türkçe tarih formatı (gg.aa.yyyy) kullanılıyor
5. **Öğrenci bilgileri HTML formatı**: Çoklu öğrenci desteği ile HTML liste oluşturuluyor

### Veri Kaynakları
- **Kulüp bilgileri**: `clubData` (Supabase'den `club_{clubId}` kaydından yükleniyor)
- **Üye bilgileri**: Form inputlarından (`fullName`, `tcno`, `phone`, `address`, `birthDate`)
- **Branş bilgisi**: `clubBranches` dizisi (Supabase'den `club_{clubId}` settings'inden)
- **Ödeme planı**: `currentPreRegistration.paymentSchedule` (Firebase/Supabase)

## ✅ Test Senaryoları

1. ✅ Kulüp bilgileri doğru gösteriliyor
2. ✅ Üye/Veli bilgileri doğru gösteriliyor
3. ✅ Branş adı doğru gösteriliyor
4. ✅ Öğrenci bilgileri (çocuk kayıtlarında) tablo halinde gösteriliyor
5. ✅ Aidat takvimi tablo halinde gösteriliyor
6. ✅ Tarih Türkçe formatında gösteriliyor
7. ✅ İkinci veli bilgileri (varsa) gösteriliyor

## 📝 Önemli Notlar

1. **Kulüp bilgileri elle yazılabilir**: Placeholder kullanmak zorunda değilsiniz, direkt metin de yazabilirsiniz
2. **Alternatif formatlar**: Bazı placeholder'ların birden fazla versiyonu var (örn: `{UYE_AD_SOYAD}` veya `{Ad_Soyad}`)
3. **Büyük/küçük harf duyarlılığı**: Placeholder'lar büyük/küçük harfe duyarlıdır
4. **Boş değerler**: Eğer bir veri yoksa, placeholder boş string ile değiştirilir
5. **HTML içeriği**: `{OGRENCI_BILGILERI}` ve `{AIDAT_TAKVIMI}` otomatik HTML tabloları oluşturur

## 🚀 Sonuç

Artık admin panelde sözleşme şablonunda bu placeholder'ları kullanabilirsiniz ve kayıt sırasında otomatik olarak gerçek verilerle değiştirilecektir. Bu sayede her kulüp kendi sözleşmesini özelleştirebilir ve dinamik içerik kullanabilir.

