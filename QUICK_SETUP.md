# ⚡ WhatsApp Mesaj Sistemi - Hızlı Kurulum

## 🚀 1. ADIM: SQL Dosyasını Çalıştırın

1. Supabase Dashboard'a gidin: https://supabase.edu-ai.online
2. Sol menüden **SQL Editor**'ı açın
3. **New Query** tıklayın
4. `whatsapp-credit-system.sql` dosyasının **tamamını** kopyalayıp yapıştırın
5. **RUN** butonuna tıklayın

### ⚠️ ÖNEMLİ: Club ID'nizi Değiştirin!

SQL dosyasında şu satırı bulun (satır 13):

```sql
INSERT INTO clubs (id, name, whatsapp_balance) VALUES
('FmvoFvTCek44CR3pS4XC', 'Atakum Tenis Kulübü', 100)
```

**Kendi kulüp ID'nizi buraya yazın!** 

Kulüp ID'nizi öğrenmek için:
1. Admin paneline giriş yapın
2. Browser Console'u açın (F12)
3. Şu komutu yazın: `console.log(currentClubId)`
4. Çıkan ID'yi kopyalayın (örn: `FmvoFvTCek44CR3pS4XC`)

SQL dosyasını düzenleyin:
```sql
INSERT INTO clubs (id, name, whatsapp_balance) VALUES
('KENDI_CLUB_ID_NIZ', 'Kulüp Adınız', 100)  -- ⚠️ BURAYA KENDİ ID'NİZİ YAZIN!
```

---

## ✅ 2. ADIM: Kurulumu Doğrulayın

SQL çalıştıktan sonra kontrol edin:

```sql
-- Tabloları kontrol et
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name LIKE '%whatsapp%';

-- Beklenen sonuç:
-- whatsapp_packages
-- whatsapp_balance_logs

-- Paketleri kontrol et
SELECT * FROM whatsapp_packages;

-- Beklenen: 5 paket görmelisiniz

-- Kulübünüzü kontrol et
SELECT * FROM clubs;

-- Beklenen: Kulübünüz ve 100 başlangıç bakiyesi
```

---

## 🎨 3. ADIM: Superadmin'de Test Edin

1. Superadmin paneline girin
2. **WhatsApp Paketleri** menüsüne tıklayın
3. 5 paket görmelisiniz
4. **Kulüpler** > [Kulübünüz] > **Admin Bilgileri**
5. WhatsApp Mesaj Hakkı bölümünü görmelisiniz
6. "➕ Mesaj Hakkı Ekle" butonunu test edin

---

## 👤 4. ADIM: Admin Panelde Test Edin

1. Admin paneline girin
2. **WhatsApp** > **💰 WhatsApp Bakiyem**
3. Şunları görmelisiniz:
   - Mevcut bakiyeniz (100)
   - 5 satın alınabilir paket
   - İşlem geçmişi (eğer ekleme yaptıysanız)

---

## 🐛 Sorun Giderme

### Hata: "relation public.whatsapp_packages does not exist"

**Çözüm:** SQL dosyasını henüz çalıştırmadınız.
- Adım 1'e geri dönün
- SQL dosyasını Supabase SQL Editor'de çalıştırın

### Hata: "club_id not found" veya "Kulüp bulunamadı"

**Çözüm:** Club ID'nizi SQL dosyasına eklemediniz.
- SQL dosyasında satır 13'ü bulun
- Kendi club ID'nizi yazın
- SQL'i tekrar çalıştırın (INSERT ... ON CONFLICT ... sayesinde güvenle tekrar çalıştırabilirsiniz)

### Admin panelde "❌ Yüklenirken Hata Oluştu"

**Çözüm 1:** Club ID eksik
```sql
-- Club'ınızı manuel ekleyin
INSERT INTO clubs (id, name, whatsapp_balance) VALUES
('CLUB_ID_NIZ', 'Kulüp Adınız', 100)
ON CONFLICT (id) DO UPDATE SET whatsapp_balance = 100;
```

**Çözüm 2:** Browser console'da kontrol edin
```javascript
// Admin panelde F12 > Console
console.log('Current Club ID:', currentClubId);

// Supabase'de varmı kontrol et
const { data, error } = await window.supabase
    .from('clubs')
    .select('*')
    .eq('id', currentClubId);
console.log('Club Data:', data, 'Error:', error);
```

### Superadmin'de paketler görünmüyor

**Çözüm:** Paketler eklenmemiş
```sql
-- Paketleri manuel ekleyin
INSERT INTO whatsapp_packages (name, message_count, price, description, is_active) VALUES
('Başlangıç Paketi', 500, 99.00, '500 WhatsApp mesajı', true),
('Standart Paket', 1000, 179.00, '1000 WhatsApp mesajı', true),
('Premium Paket', 2500, 399.00, '2500 WhatsApp mesajı', true),
('Profesyonel Paket', 5000, 699.00, '5000 WhatsApp mesajı', true),
('Kurumsal Paket', 10000, 1199.00, '10000 WhatsApp mesajı', true)
ON CONFLICT DO NOTHING;
```

---

## 📞 Yardım

Sorun devam ederse:
- Browser Console'daki hata mesajlarını kontrol edin
- Supabase logs'ları inceleyin (Dashboard > Logs)
- Telefon: 0362 363 00 63

---

## ✅ Kurulum Tamamlandı!

Sistem artık kullanıma hazır. Şunları yapabilirsiniz:

- ✅ Superadmin: Paket yönetimi
- ✅ Superadmin: Kulüplere bakiye ekleme
- ✅ Admin: Bakiye görüntüleme
- ✅ Admin: Paket listeleme
- ✅ İşlem geçmişi takibi

**Sonraki adımlar için:** `WHATSAPP_CREDIT_SYSTEM_GUIDE.md` dosyasına bakın.
