# Mesai Saatleri - Cihaz Bazlı Güncelleme

## 📋 Özet
Cevapsız arama senaryosundaki mesai saatleri kontrolü, **club settings** yerine **whatsapp cihazlarının kendi ayarlarından** alınacak şekilde güncellendi.

## 🔄 Değişiklikler

### 1. Database Değişikliği
**Dosya:** `add-messageSendingHours-to-whatsappDevices.sql`

`whatsappDevices` tablosuna `message_sending_hours` kolonu eklendi:

```sql
ALTER TABLE "whatsappDevices"
ADD COLUMN message_sending_hours jsonb 
DEFAULT '{"enabled":true,"days":[1,2,3,4,5],"start":"09:00","end":"18:00"}';
```

**Default Değerler:**
- `enabled`: true (aktif)
- `days`: [1,2,3,4,5] (Pazartesi-Cuma)
- `start`: "09:00"
- `end`: "18:00"

### 2. Kod Değişiklikleri
**Dosya:** `combined-auto-reply-system.js`

#### ✅ WhatsApp Cihaz Sorgusu Güncellendi
```javascript
// ÖNCE:
.select('id, instanceName, phoneNumber')

// SONRA:
.select('id, instanceName, phoneNumber, message_sending_hours')
```

#### ✅ Mesai Saati Kontrolü Değişti
```javascript
// ÖNCE (yanlış - club ayarlarından):
if (!checkBusinessHours(callTime, clubSettings.messageSendingHours)) {

// SONRA (doğru - cihazın kendi ayarlarından):
if (!checkBusinessHours(callTime, device.message_sending_hours)) {
```

#### ✅ Kontrol Sırası Değişti
**ÖNCE:** Mesai kontrolü → Cihaz eşleştirme  
**SONRA:** Cihaz eşleştirme → Mesai kontrolü (mantıklı)

## 🎯 Neden Bu Değişiklik?

### Eski Yapı Sorunu:
- Tüm club için tek mesai saati vardı (`clubSettings.messageSendingHours`)
- Farklı cihazlar farklı saatlerde mesaj gönderemiyordu

### Yeni Yapı Avantajları:
✅ Her cihazın kendi mesaj gönderim saatleri olabilir  
✅ Cihaz bazlı esneklik (örn: Cihaz 1 → 09:00-18:00, Cihaz 2 → 10:00-20:00)  
✅ CRM arayüzünden cihaz bazlı ayar yapılabilir  
✅ Daha detaylı kontrol

## 📊 Etkilenen Senaryolar

### ✅ Etkilenen:
- **Cevapsız Aramalar** (`processMissedCalls`)
  - Artık cihazın `message_sending_hours` ayarına göre kontrol edilir

### ❌ Etkilenmeyen:
- Gecikmiş Ödemeler
- Devamsızlık Uyarıları
- Yaklaşan Ödeme Hatırlatmaları
- Deneme Dersi Hatırlatmaları

*(Bu senaryolar zaten şablonun `send_time` ayarına göre çalışıyor)*

## 🚀 Deployment

**Git Commit:**
```bash
git commit -m "fix: Mesai saatleri cihaz bazlı (whatsappDevices.message_sending_hours)"
git push origin master
```

**Coolify:** Otomatik deploy olacak (GitHub webhook ile)

## ⚠️ Önemli Notlar

### 1. SQL Çalıştırılmalı
`add-messageSendingHours-to-whatsappDevices.sql` dosyası Supabase'de çalıştırılmalı:

```sql
-- Kolon ekle
ALTER TABLE "whatsappDevices"
ADD COLUMN message_sending_hours jsonb 
DEFAULT '{"enabled":true,"days":[1,2,3,4,5],"start":"09:00","end":"18:00"}';

-- Mevcut kayıtlara default değer ata
UPDATE "whatsappDevices"
SET message_sending_hours = '{"enabled":true,"days":[1,2,3,4,5],"start":"09:00","end":"18:00"}'
WHERE message_sending_hours IS NULL;
```

### 2. CRM Arayüzü Güncellenmeli
**WhatsApp Cihazlar** sayfasında her cihaz için mesaj gönderim saatleri ayarı eklenebilir:

```
Mesaj Gönderim Saatleri
------------------------
☑ Aktif
Günler: Pzt Sal Çar Per Cum
Başlangıç: 09:00
Bitiş: 18:00
```

### 3. Veri Yapısı
```json
{
  "enabled": true,
  "days": [1, 2, 3, 4, 5],
  "start": "09:00",
  "end": "18:00"
}
```

**Günler (days):**
- 0 = Pazar
- 1 = Pazartesi
- 2 = Salı
- 3 = Çarşamba
- 4 = Perşembe
- 5 = Cuma
- 6 = Cumartesi

## 📝 Test Senaryosu

1. **Mesai içinde arama:**
   - Saat: 10:00 (Pazartesi)
   - Cihaz ayarı: 09:00-18:00, Pzt-Cum
   - Sonuç: ✅ Mesaj gönderilir

2. **Mesai dışı saat:**
   - Saat: 20:00 (Pazartesi)
   - Cihaz ayarı: 09:00-18:00, Pzt-Cum
   - Sonuç: ❌ Mesaj gönderilmez

3. **Mesai dışı gün:**
   - Saat: 10:00 (Cumartesi)
   - Cihaz ayarı: 09:00-18:00, Pzt-Cum
   - Sonuç: ❌ Mesaj gönderilmez

4. **Cihaz devre dışı:**
   - Saat: 10:00 (Pazartesi)
   - Cihaz ayarı: enabled=false
   - Sonuç: ❌ Mesaj gönderilmez

## 🔗 İlgili Dosyalar
- `combined-auto-reply-system.js` → Ana sistem kodu
- `add-messageSendingHours-to-whatsappDevices.sql` → Database migration
- `message_templates` → Şablon ayarları (diğer 4 senaryo için)

---

**Güncelleme Tarihi:** 2025  
**Commit:** cc3572c
