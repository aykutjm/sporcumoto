# 🔍 CRM Dropdown Menüler - Kontrol Rehberi

## ✅ Eklenen Dropdown'lar

CRM sayfasında **"Potansiyel Müşteriler"** kartının üstünde **5 dropdown** var:

1. **Tüm Durumlar** (çalışıyor - dolu)
2. **Tüm Branşlar** (çalışıyor - dolu)
3. **Müşteri Filtrele** ⭐ YENİ (boş - siz dolduracaksınız)
4. **Denemeler** ⭐ YENİ (boş - siz dolduracaksınız)
5. **Etiketler** ⭐ YENİ (boş - siz dolduracaksınız)

---

## 📍 Konumları

```
CRM Sayfası
  └─ Potansiyel Müşteriler Kartı
      └─ Başlık: "👥 Potansiyel Müşteriler"
          └─ Sağ Taraf: [5 Dropdown Yan Yana]
```

---

## 🎨 Görünüm

```
[Tüm Durumlar ▼] [Tüm Branşlar ▼] [Müşteri Filtrele ▼] [Denemeler ▼] [Etiketler ▼]
```

**Not:** Boş dropdown'lar gri ve tıklanabilir ama içinde seçenek yok (sadece başlık).

---

## 🔧 Sorun Giderme

### Eğer Dropdown'lar Görünmüyorsa:

#### 1. **Sayfayı Yenile**
```
Ctrl + F5 (Hard Refresh)
```
Cache'den eski sayfa açılmış olabilir.

#### 2. **CRM Sayfasına Git**
- Sol menüden "📊 CRM" butonuna tıklayın
- "Potansiyel Müşteriler" kartını bulun

#### 3. **Ekran Genişliği**
Eğer ekran dar ise, dropdown'lar alt satıra inmiş olabilir. Tarayıcı penceresini genişletin.

#### 4. **Console Hatası Kontrol**
- F12 tuşuna basın
- Console sekmesine bakın
- Kırmızı hata var mı kontrol edin

#### 5. **HTML Kontrolü**
F12 → Elements → Bu ID'leri arayın:
- `crm-customer-filter`
- `crm-trials-filter`
- `crm-tags-filter`

Eğer varsa = Dropdown'lar yüklendi ✅

---

## 📝 Dropdown'ları Doldurmak

### Müşteri Filtrele - Örnek Seçenekler:

**admin.html** dosyasında satır ~12723:

```html
<select id="crm-customer-filter" class="form-control" style="width: 160px;" onchange="renderCRMLeads()">
    <option value="" selected disabled>Müşteri Filtrele</option>
    <!-- Buraya ekleyin: -->
    <option value="vip">⭐ VIP Müşteri</option>
    <option value="potansiyel">🎯 Potansiyel</option>
    <option value="yeni">🆕 Yeni Müşteri</option>
    <option value="takipte">👀 Takipte</option>
</select>
```

### Denemeler - Örnek Seçenekler:

**admin.html** dosyasında satır ~12727:

```html
<select id="crm-trials-filter" class="form-control" style="width: 140px;" onchange="renderCRMLeads()">
    <option value="" selected disabled>Denemeler</option>
    <!-- Buraya ekleyin: -->
    <option value="planli">📅 Planlandı</option>
    <option value="tamamlandi">✅ Tamamlandı</option>
    <option value="iptal">❌ İptal Edildi</option>
    <option value="bekleniyor">⏳ Bekliyor</option>
</select>
```

### Etiketler - Örnek Seçenekler:

**admin.html** dosyasında satır ~12731:

```html
<select id="crm-tags-filter" class="form-control" style="width: 140px;" onchange="renderCRMLeads()">
    <option value="" selected disabled>Etiketler</option>
    <!-- Buraya ekleyin: -->
    <option value="sicak">🔥 Sıcak Lead</option>
    <option value="soguk">❄️ Soğuk Lead</option>
    <option value="acil">🚨 Acil</option>
    <option value="oncelikli">⭐ Öncelikli</option>
</select>
```

---

## 🔍 Filtreleme Mantığını Eklemek

Şu anda dropdown'lar sadece görsel. Filtreleme yapmıyorlar. 

Filtreleme eklemek için **admin.html** dosyasında satır ~6745'e gidin:

```javascript
// ✅ Ek filtreler buraya eklenebilir (müşteri filtrele, denemeler, etiketler)

// Müşteri Filtresi
const customerFilter = document.getElementById('crm-customer-filter')?.value;
if (customerFilter) {
    filteredLeads = filteredLeads.filter(l => l.customerType === customerFilter);
}

// Deneme Filtresi
const trialsFilter = document.getElementById('crm-trials-filter')?.value;
if (trialsFilter) {
    filteredLeads = filteredLeads.filter(l => l.trialStatus === trialsFilter);
}

// Etiket Filtresi
const tagsFilter = document.getElementById('crm-tags-filter')?.value;
if (tagsFilter) {
    filteredLeads = filteredLeads.filter(l => l.tags && l.tags.includes(tagsFilter));
}
```

**Not:** Bu özellik için veritabanında ilgili alanları da eklemeniz gerekir (`customerType`, `trialStatus`, `tags`).

---

## ✅ Test Adımları

1. **Sayfayı aç:** `admin.html`
2. **CRM menüsüne git**
3. **Potansiyel Müşteriler** kartına bak
4. **5 dropdown görmeli:**
   - Tüm Durumlar (dolu) ✅
   - Tüm Branşlar (dolu) ✅
   - Müşteri Filtrele (boş) ✅
   - Denemeler (boş) ✅
   - Etiketler (boş) ✅

---

## 📞 Hala Görünmüyor mu?

Aşağıdaki bilgileri verin:

1. ✅ Sayfayı Ctrl+F5 ile yeniledim
2. ✅ CRM sayfasındayım
3. ❓ Console'da hata var mı? (F12 → Console)
4. ❓ Elements'te ID'ler var mı? (F12 → Elements → Ara: `crm-customer-filter`)
5. ❓ Ekran genişliği yeterli mi? (min 1200px önerilen)

Bu bilgilerle sorunu daha iyi çözebilirim.

