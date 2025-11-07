# ✅ Supabase Kurulum Checklist

Bu listeyi takip ederek Supabase kurulumunuzu tamamlayın.

## 📋 Ön Hazırlık

- [ ] Supabase sunucunuz hazır
- [ ] Supabase Dashboard'a erişiminiz var
- [ ] Firebase Service Account Key'i indirildi (`serviceAccountKey.json`)

## 🔧 1. Supabase Bilgilerini Edinme

- [ ] Supabase Dashboard → Project Settings → API açıldı
- [ ] Project URL kopyalandı
- [ ] anon/public key kopyalandı
- [ ] service_role key kopyalandı

## 📝 2. HTML Dosyalarını Güncelleme

Her dosyada `YOUR_SUPABASE_URL` ve `YOUR_SUPABASE_ANON_KEY` değerlerini kendi bilgilerinizle değiştirin:

- [ ] `uyeyeni/admin.html` (satır 15-16)
  ```javascript
  const SUPABASE_URL = 'https://your-project.supabase.co';
  const SUPABASE_ANON_KEY = 'your-anon-key';
  ```

- [ ] `uyeyeni/superadmin.html` (satır 14-15)
  ```javascript
  const SUPABASE_URL = 'https://your-project.supabase.co';
  const SUPABASE_ANON_KEY = 'your-anon-key';
  ```

- [ ] `uyeyeni/giris.html` (satır 24-25)
  ```javascript
  const SUPABASE_URL = 'https://your-project.supabase.co';
  const SUPABASE_ANON_KEY = 'your-anon-key';
  ```

- [ ] `uyeyeni/kayit.html` (satır 16-17)
  ```javascript
  const SUPABASE_URL = 'https://your-project.supabase.co';
  const SUPABASE_ANON_KEY = 'your-anon-key';
  ```

- [ ] `uyeyeni/uye.html` (satır 14-15)
  ```javascript
  const SUPABASE_URL = 'https://your-project.supabase.co';
  const SUPABASE_ANON_KEY = 'your-anon-key';
  ```

## 🗄️ 3. Veritabanı Oluşturma

- [ ] Supabase Dashboard açıldı
- [ ] SQL Editor seçildi
- [ ] `supabase-schema.sql` dosyası açıldı
- [ ] SQL içeriği tamamı kopyalandı
- [ ] SQL Editor'e yapıştırıldı
- [ ] **Run** butonuna tıklandı
- [ ] Hata yok, 25 tablo oluşturuldu

**Kontrol:**
```
✅ clubs
✅ settings
✅ users
✅ members
✅ pre_registrations
✅ groups
✅ schedules
✅ attendance_records
✅ crm_leads
✅ crm_tags
✅ whatsapp_devices
✅ whatsapp_incoming_calls
✅ whatsapp_incoming_messages
✅ whatsapp_messages
✅ sent_messages
✅ message_queue
✅ scheduled_messages
✅ campaigns
✅ tasks
✅ expenses
✅ products
✅ webhooks
✅ user_activities
✅ holidays
✅ branches
```

## 📦 4. NPM Dependencies

- [ ] Terminal/CMD açıldı
- [ ] Proje klasörüne gidildi (`cd sporcum-supabase`)
- [ ] `npm install` çalıştırıldı
- [ ] Dependencies başarıyla yüklendi

## 🔥 5. Firebase Export

- [ ] `serviceAccountKey.json` proje kök dizinine kopyalandı
- [ ] Terminal'de: `npm run export` çalıştırıldı
- [ ] `exports/` klasörü oluşturuldu
- [ ] `firebase-export-[timestamp].json` dosyası oluşturuldu
- [ ] Export özeti görüntülendi

**Beklenen çıktı:**
```
✅ Exported XX documents from clubs
✅ Exported XX documents from members
✅ Exported XX documents from preRegistrations
... (diğerleri)
📦 Total: XXX documents exported
```

## 📥 6. Supabase Import

- [ ] `supabase-import.js` dosyası açıldı
- [ ] Satır 11-12: Supabase URL ve Service Role Key güncellendi
  ```javascript
  const SUPABASE_URL = 'https://your-project.supabase.co';
  const SUPABASE_SERVICE_KEY = 'your-service-role-key';
  ```
- [ ] Dosya kaydedildi
- [ ] Terminal'de: `npm run import` çalıştırıldı
- [ ] Import başarıyla tamamlandı

**Beklenen çıktı:**
```
✅ clubs: XX success, 0 errors
✅ members: XX success, 0 errors
✅ preRegistrations: XX success, 0 errors
... (diğerleri)
📦 Total: XXX imported, 0 errors
```

## 🧪 7. Test & Doğrulama

### Giriş Testi
- [ ] `uyeyeni/giris.html` sayfası açıldı
- [ ] Email ve şifre ile giriş yapıldı
- [ ] Başarıyla giriş yapıldı
- [ ] Dashboard'a yönlendirildi

### Dashboard Testi
- [ ] Üye sayısı gösteriliyor
- [ ] Grafik ve istatistikler yükleniyor
- [ ] Sidebar menü çalışıyor

### Üye Yönetimi Testi
- [ ] Üyeler listesi görüntülendi
- [ ] Arama çalışıyor
- [ ] Filtreleme çalışıyor
- [ ] Yeni üye ekleme testi yapıldı
- [ ] Üye düzenleme testi yapıldı
- [ ] Üye silme testi yapıldı (dikkatli!)

### Ön Kayıt Testi
- [ ] Ön kayıtlar listesi görüntülendi
- [ ] Yeni ön kayıt eklendi
- [ ] Ön kayıt düzenlendi
- [ ] Ön kayıt üyeliğe dönüştürüldü

### CRM Testi
- [ ] CRM Leads listesi görüntülendi
- [ ] Yeni lead eklendi
- [ ] Lead durumu güncellendi
- [ ] Tag sistemi çalışıyor

### WhatsApp Testi (varsa)
- [ ] Cihazlar listesi görüntülendi
- [ ] Gelen aramalar görüntülendi
- [ ] Mesaj gönderme testi yapıldı

### Program/Takvim Testi
- [ ] Programlar listesi görüntülendi
- [ ] Yeni program eklendi
- [ ] Grup ataması yapıldı

## 🔐 8. Superadmin Ayarları

- [ ] `superadmin.html` sayfası açıldı
- [ ] Superadmin giriş bilgileri oluşturuldu
- [ ] F12 → Console açıldı
- [ ] `create-superadmin.js` içeriği yapıştırıldı
- [ ] `createSuperAdminConfig()` çalıştırıldı
- [ ] Superadmin bilgileri kaydedildi

## 🎨 9. Özelleştirme (Opsiyonel)

- [ ] Kulüp adı güncellendi
- [ ] Logo/icon eklendi
- [ ] Renk teması ayarlandı
- [ ] Branşlar eklendi

## 📱 10. Realtime Testi

- [ ] İki tarayıcı/tab açıldı
- [ ] Birinde üye eklendi
- [ ] Diğerinde otomatik güncellendi
- [ ] Realtime çalışıyor

## ⚙️ 11. RLS (Row Level Security) Ayarları

- [ ] Supabase Dashboard → Authentication kontrol edildi
- [ ] RLS politikaları kontrol edildi
- [ ] Test kullanıcıları sadece kendi kulüplerini görebiliyor

## 🔍 12. Sorun Giderme

Bir sorun varsa kontrol edin:

**Browser Console (F12)**
- [ ] Console'da hata var mı?
- [ ] Network tab'da failed request var mı?
- [ ] Supabase request'leri 200 dönüyor mu?

**Supabase Dashboard**
- [ ] Database → Tables kontrol edildi
- [ ] Veriler görünüyor mu?
- [ ] Logs → Recent Logs kontrol edildi

**Yaygın Hatalar:**
- [ ] "YOUR_SUPABASE_URL" hatası → HTML dosyaları güncellenmiş mi?
- [ ] "relation does not exist" → SQL schema çalıştırıldı mı?
- [ ] "permission denied" → RLS politikaları kontrol edildi mi?
- [ ] Veri görünmüyor → club_id filter doğru mu?

## 🎉 13. Tamamlandı!

- [ ] Tüm testler başarılı
- [ ] Firebase verilerine dokunulmadı (kontrol edildi)
- [ ] Supabase versiyonu çalışıyor
- [ ] Dokümantasyon okundu
- [ ] Yedek alındı

---

## 📊 İlerleme

**Tamamlanan:** ____ / 60+ adım

## 📝 Notlar

Kurulum sırasında karşılaştığınız sorunları buraya yazın:

```
[Buraya notlarınızı yazın]
```

---

**Başlangıç:** ____/____/____  
**Bitiş:** ____/____/____  
**Durum:** [ ] Devam Ediyor [ ] Tamamlandı

🎉 **Başarılar dileriz!**

