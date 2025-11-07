# 🚀 Sporcum CRM - Supabase Edition

Bu proje Firebase'den Supabase'e geçiş için hazırlandı. **Orijinal Firebase projenize hiçbir şey yapılmadı.**

## 🎯 Hızlı Başlangıç

### 1. Supabase Bilgilerini Güncelleyin

**5 HTML dosyasında** bu satırları bulup güncelleyin:

```javascript
const SUPABASE_URL = 'https://your-project.supabase.co';  // ← KENDİ URL'İNİZ
const SUPABASE_ANON_KEY = 'your-anon-key';  // ← KENDİ KEY'İNİZ
```

**Dosyalar:**
- `uyeyeni/admin.html` (satır 15-16)
- `uyeyeni/superadmin.html` (satır 14-15)
- `uyeyeni/giris.html` (satır 24-25)
- `uyeyeni/kayit.html` (satır 16-17)
- `uyeyeni/uye.html` (satır 14-15)

### 2. Veritabanı Şemasını Oluşturun

```sql
-- Supabase Dashboard → SQL Editor
-- supabase-schema.sql dosyasının içeriğini kopyalayıp yapıştırın
-- Run butonuna tıklayın
```

### 3. Firebase Verilerini Aktarın

```bash
# Dependencies yükle
npm install

# Firebase'den export et
npm run export

# Supabase'e import et (önce supabase-import.js'i yapılandırın)
npm run import
```

### 4. Test Edin

`uyeyeni/giris.html` sayfasını açın ve giriş yapın!

## 📚 Detaylı Dokümantasyon

- 📖 **[SUPABASE_QUICK_START.md](SUPABASE_QUICK_START.md)** - Hızlı kurulum rehberi
- 📖 **[SUPABASE_MIGRATION_GUIDE.md](SUPABASE_MIGRATION_GUIDE.md)** - Detaylı migration rehberi  
- 📖 **[MIGRATION_SUMMARY.md](MIGRATION_SUMMARY.md)** - Yapılan değişikliklerin özeti

## 📦 Oluşturulan Dosyalar

```
📄 supabase-schema.sql        - 25 tablo SQL şeması
📄 supabase-helper.js          - Firebase API uyumluluk katmanı
📄 firebase-export.js          - Firebase export scripti
📄 supabase-import.js          - Supabase import scripti
📄 package.json                - NPM bağımlılıkları
```

## ✅ Güncellenen Dosyalar

- ✅ `uyeyeni/admin.html` - Ana panel
- ✅ `uyeyeni/superadmin.html` - Superadmin panel
- ✅ `uyeyeni/giris.html` - Giriş sayfası
- ✅ `uyeyeni/kayit.html` - Kayıt sayfası
- ✅ `uyeyeni/uye.html` - Üye portalı
- ✅ Tüm JavaScript scriptleri

## 🗄️ Veritabanı

**25 tablo** içeren tam SQL şeması:
- Kulüpler, kullanıcılar, ayarlar
- Üyeler, ön kayıtlar, gruplar, programlar
- CRM (leads, tags)
- WhatsApp (devices, calls, messages, queue)
- Kampanyalar, görevler, giderler, ürünler
- Ve daha fazlası...

## ⚠️ Önemli

- **Firebase'e dokunulmadı** - Tüm verileriniz güvende
- **İki ayrı sistem** - Firebase ve Supabase bağımsız çalışır
- **Minimum kod değişikliği** - `supabase-helper.js` ile uyumluluk

## 🆘 Yardım

Sorun mu yaşıyorsunuz?
1. `SUPABASE_QUICK_START.md` → Sorun Giderme
2. Browser Console (F12) → Hata mesajları
3. Supabase Dashboard → Logs

## 📊 İstatistikler

- **Toplam dosya:** 17 (9 yeni + 8 güncellenen)
- **Kod satırı:** ~3000+ satır
- **Tablo sayısı:** 25 tablo
- **Firebase'e dokunuldu mu?** ❌ HAYIR

---

**🎉 Kolay gelsin!**

