# 🚀 Supabase Hızlı Başlangıç

Bu proje artık **Supabase** ile çalışacak şekilde yapılandırıldı. Firebase versiyonu değiştirilmedi ve ayrı olarak çalışmaya devam edebilir.

## 📦 Yapılan Değişiklikler

### ✅ Oluşturulan Dosyalar

1. **`supabase-config.js`** - Supabase bağlantı ayarları
2. **`supabase-schema.sql`** - Veritabanı şeması (25 tablo)
3. **`supabase-helper.js`** - Firebase API uyumluluk katmanı
4. **`firebase-export.js`** - Firebase'den veri export scripti
5. **`supabase-import.js`** - Supabase'e veri import scripti
6. **`package.json`** - NPM bağımlılıkları
7. **`SUPABASE_MIGRATION_GUIDE.md`** - Detaylı migration rehberi

### ✅ Güncellenen Dosyalar

Tüm HTML dosyaları Firebase yerine Supabase kullanacak şekilde güncellendi:
- ✅ `uyeyeni/admin.html` - Ana yönetim paneli
- ✅ `uyeyeni/superadmin.html` - Süper admin paneli
- ✅ `uyeyeni/giris.html` - Giriş sayfası
- ✅ `uyeyeni/kayit.html` - Kayıt/sözleşme sayfası
- ✅ `uyeyeni/uye.html` - Üye portalı
- ✅ `toplu_musteri_ekle.js` - Toplu müşteri ekleme scripti
- ✅ `update_prereg_script.js` - Ön kayıt güncelleme scripti
- ✅ `uyeyeni/create-superadmin.js` - Superadmin oluşturma scripti

### ⚠️ Önemli Notlar

- **Firebase'e hiçbir şey yapılmadı** - Mevcut Firebase projeniz (`uyekayit-5964b`) değişmeden kaldı
- **İki ayrı versiyon** - Firebase ve Supabase versiyonları bağımsız çalışır
- **Uyumluluk katmanı** - `supabase-helper.js` Firebase API'sini taklit eder, kod değişikliği minimum

## 🔧 Kurulum Adımları

### 1. Supabase URL ve Key'lerini Alın

Kendi Supabase sunucunuza gidin:
- Dashboard → Project Settings → API
- **Project URL** kopyalayın
- **anon/public key** kopyalayın  
- **service_role key** kopyalayın (sadece import için)

### 2. Tüm HTML Dosyalarında Supabase Config'i Güncelleyin

Aşağıdaki dosyalarda `YOUR_SUPABASE_URL` ve `YOUR_SUPABASE_ANON_KEY` değerlerini değiştirin:

```javascript
// Tüm HTML dosyalarında bu satırları bulun ve güncelleyin:
const SUPABASE_URL = 'https://your-project.supabase.co';  // ← Buraya kendi URL'inizi yazın
const SUPABASE_ANON_KEY = 'your-anon-key';  // ← Buraya kendi anon key'inizi yazın
```

**Güncellenecek dosyalar:**
- ✏️ `uyeyeni/admin.html` (satır 15-16)
- ✏️ `uyeyeni/superadmin.html` (satır 14-15)
- ✏️ `uyeyeni/giris.html` (satır 24-25)
- ✏️ `uyeyeni/kayit.html` (satır 16-17)
- ✏️ `uyeyeni/uye.html` (satır 14-15)

### 3. Supabase Veritabanı Şemasını Oluşturun

1. Supabase Dashboard'a gidin
2. **SQL Editor**'ü açın
3. `supabase-schema.sql` dosyasını açın
4. Tüm içeriği kopyalayın
5. SQL Editor'e yapıştırın
6. **Run** butonuna tıklayın

Bu işlem:
- ✅ 25 tablo oluşturur
- ✅ İndeksleri ekler
- ✅ Foreign key ilişkilerini kurar
- ✅ Row Level Security (RLS) politikalarını ekler
- ✅ Otomatik güncelleme trigger'larını kurar

### 4. Firebase Verilerini Export Edin

**Gereksinim:** Firebase Service Account Key

1. [Firebase Console](https://console.firebase.google.com) → Projeniz
2. Project Settings → Service Accounts
3. "Generate New Private Key" → İndirin
4. Dosyayı proje klasörüne `serviceAccountKey.json` olarak kaydedin

```bash
# Dependencies yükle
npm install

# Firebase'den veri export et
npm run export
```

Export dosyası `exports/firebase-export-[timestamp].json` olarak kaydedilecek.

### 5. Supabase'e Veri Import Edin

`supabase-import.js` dosyasını açın ve Supabase bilgilerinizi güncelleyin:

```javascript
const SUPABASE_URL = 'https://your-project.supabase.co';
const SUPABASE_SERVICE_KEY = 'your-service-role-key';  // ⚠️ Service role key
```

Sonra import çalıştırın:

```bash
npm run import
```

Bu işlem:
- ✅ Export edilen verileri okur
- ✅ Supabase tablolarına aktarır
- ✅ Foreign key sırasına göre import yapar
- ✅ Özet rapor gösterir

### 6. Test Edin!

1. `uyeyeni/giris.html` sayfasını açın
2. Admin bilgilerinizle giriş yapın
3. Dashboard'ın yüklendiğini kontrol edin
4. Üye, grup, program gibi verileri test edin

## 🎯 Hızlı Test Checklist

- [ ] Supabase URL ve Key'ler tüm HTML dosyalarında güncellendi
- [ ] `supabase-schema.sql` Supabase'de çalıştırıldı
- [ ] Firebase veriler export edildi (`npm run export`)
- [ ] Veriler Supabase'e import edildi (`npm run import`)
- [ ] Giriş yapılabiliyor
- [ ] Dashboard verileri gösteriyor
- [ ] CRUD işlemleri çalışıyor (Ekle/Düzenle/Sil)
- [ ] CRM özellikleri çalışıyor

## 🔐 Authentication

Kullanıcılar Supabase'de yeniden oluşturulmalı:

### Option 1: Supabase Dashboard'dan Manuel Oluştur
1. Authentication → Users → Add User
2. Email ve şifre girin

### Option 2: Superadmin Script ile Oluştur
1. `superadmin.html` sayfasını açın
2. F12 → Console
3. `uyeyeni/create-superadmin.js` içeriğini yapıştırın
4. `createSuperAdminConfig()` çalıştırın

## 📊 Veri Yapısı

Supabase şeması şu tabloları içerir:

### Ana Tablolar
- `clubs` - Kulüpler
- `users` - Kullanıcılar (admin/superadmin)
- `members` - Aktif üyeler
- `pre_registrations` - Ön kayıtlar
- `branches` - Spor branşları
- `groups` - Gruplar
- `schedules` - Programlar
- `attendance_records` - Yoklama kayıtları

### CRM Tabloları
- `crm_leads` - Potansiyel müşteriler
- `crm_tags` - CRM etiketleri

### WhatsApp Tabloları
- `whatsapp_devices` - WhatsApp cihazları
- `whatsapp_incoming_calls` - Gelen aramalar
- `whatsapp_incoming_messages` - Gelen mesajlar
- `whatsapp_messages` - Giden mesajlar
- `sent_messages` - Mesaj geçmişi
- `message_queue` - Mesaj kuyruğu
- `scheduled_messages` - Zamanlanmış mesajlar

### Diğer Tablolar
- `campaigns` - Kampanyalar
- `tasks` - Görevler
- `expenses` - Giderler
- `products` - Ürünler
- `webhooks` - Webhook ayarları
- `user_activities` - Kullanıcı aktiviteleri
- `holidays` - Tatiller
- `settings` - Ayarlar

## 🔄 Supabase Helper API

`supabase-helper.js` Firebase API'sini taklit eder:

```javascript
// Firebase tarzı kullanım (otomatik Supabase'e dönüşür)
window.firebase.collection(window.db, 'members')
window.firebase.addDoc(collectionRef, data)
window.firebase.getDocs(collectionRef)
window.firebase.updateDoc(docRef, data)
window.firebase.deleteDoc(docRef)
window.firebase.query(collectionRef, where('status', '==', 'active'))
```

**Otomatik Dönüşümler:**
- ✅ camelCase → snake_case (field adları)
- ✅ Collection adları (preRegistrations → pre_registrations)
- ✅ club_id otomatik ekleme
- ✅ Realtime subscriptions

## ⚠️ Önemli Farklılıklar

### Firebase'den Farklı Olanlar

1. **Auth:**
   - Firebase: `signInWithEmailAndPassword(auth, email, pass)`
   - Supabase: `auth.signInWithEmailAndPassword(email, pass)`

2. **Subcollections:**
   - Firebase: `clubs/{clubId}/crmTags`
   - Supabase: `crm_tags` tablosu + `club_id` filter

3. **Field Names:**
   - Firebase: camelCase (`fullName`, `createdAt`)
   - Supabase: snake_case (`full_name`, `created_at`)
   - ✅ Helper otomatik dönüştürür

4. **IDs:**
   - Firebase: Random string (`xYz123AbC`)
   - Supabase: UUID (`123e4567-e89b-12d3-a456-426614174000`)

## 🆘 Sorun Giderme

### "YOUR_SUPABASE_URL is not defined"
→ HTML dosyalarında Supabase config'i güncellenmemiş

### "relation does not exist"
→ `supabase-schema.sql` henüz çalıştırılmamış

### "permission denied for table"
→ RLS politikalarını kontrol edin veya service role key kullanın

### Veriler görünmüyor
→ Browser console'da hata kontrol edin
→ club_id filter'ı doğru uygulanıyor mu kontrol edin

### Authentication çalışmıyor
→ Supabase → Authentication → Email ayarlarını kontrol edin
→ Email confirmation disabled yapın (development için)

## 📞 İletişim & Destek

Sorun yaşarsanız:
1. Browser console'u kontrol edin (F12)
2. Supabase Dashboard → Logs kontrol edin
3. `SUPABASE_MIGRATION_GUIDE.md` detaylı rehbere bakın

## 🎉 Başarıyla Kuruldu!

Artık projeniz Supabase ile çalışıyor! Firebase versiyonu hiç değiştirilmedi ve eski projeniz aynen çalışmaya devam ediyor.

---

**Hazırlayan:** AI Assistant  
**Tarih:** 2025-11-02  
**Versiyon:** 1.0

