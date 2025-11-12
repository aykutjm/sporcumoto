# WhatsApp Mesaj Hakkı Sistemi - Kurulum ve Kullanım Kılavuzu

## 📋 Genel Bakış

Bu sistem, spor kulüplerinin WhatsApp mesaj hakkını yönetmelerini sağlar. Kulüpler paket satın alabilir, mesaj bakiyelerini görüntüleyebilir ve superadmin her kulübün bakiyesini yönetebilir.

---

## 🗄️ 1. Veritabanı Kurulumu

### Supabase SQL Editor'de Çalıştırın:

```bash
whatsapp-credit-system.sql
```

Bu dosya şunları oluşturur:
- ✅ `clubs` tablosuna `whatsapp_balance` kolonu
- ✅ `whatsapp_packages` tablosu (mesaj paketleri)
- ✅ `whatsapp_balance_logs` tablosu (işlem geçmişi)
- ✅ Yardımcı fonksiyonlar (`update_whatsapp_balance`, `check_whatsapp_balance`)
- ✅ RLS (Row Level Security) politikaları
- ✅ Örnek paketler (500, 1000, 2500, 5000, 10000 mesaj)

### Oluşturulan Fonksiyonlar:

#### `update_whatsapp_balance()`
```sql
SELECT * FROM update_whatsapp_balance(
    p_club_id := 'kulup-uuid',
    p_amount := 500,
    p_action_type := 'manual_add',
    p_note := 'İlk yükleme'
);
```

#### `check_whatsapp_balance()`
```sql
SELECT * FROM check_whatsapp_balance(
    p_club_id := 'kulup-uuid',
    p_message_count := 10
);
```

---

## 🎛️ 2. Superadmin Paneli

### Özellikler:

#### A. WhatsApp Paketleri Yönetimi
- **Menü:** Dashboard > WhatsApp Paketleri (📱)
- **Yeni paket ekleme**
- **Paket düzenleme**
- **Paket aktif/pasif yapma**
- **Paket silme**

#### B. Kulüplere Bakiye Ekleme
- **Menü:** Kulüpler > [Kulüp Seç] > 🔐 Admin Bilgileri
- **WhatsApp Mesaj Hakkı** bölümü görüntülenir
- "➕ Mesaj Hakkı Ekle" butonu ile manuel ekleme
- Son 10 işlem geçmişi gösterilir

### Kullanım:

1. **Paket Eklemek İçin:**
   - Dashboard > WhatsApp Paketleri
   - "➕ Yeni Paket Ekle"
   - Paket bilgilerini doldurun
   - Kaydet

2. **Kulübe Bakiye Eklemek İçin:**
   - Kulüpler > [Kulüp]
   - 🔐 Admin Bilgileri
   - "➕ Mesaj Hakkı Ekle"
   - Miktar ve not girin
   - Kaydet

---

## 👨‍💼 3. Admin Paneli (Kulüp Yöneticisi)

### Özellikler:

#### WhatsApp Bakiyem Sayfası
- **Menü:** WhatsApp > 💰 WhatsApp Bakiyem
- **Mevcut bakiye görüntüleme**
- **Uyarılar:** Bakiye < 100 ise uyarı gösterilir
- **Paket Listesi:** Tüm aktif paketler
- **İşlem Geçmişi:** Son 20 işlem

### Görsel Özellikler:

```
┌─────────────────────────────────────────┐
│ 💬 Mevcut Mesaj Bakiyeniz               │
│                                         │
│    2,500 WhatsApp mesajı                │
│                                         │
│         ✅ Bakiyeniz yeterli            │
└─────────────────────────────────────────┘

📦 MESAJ PAKETLERİ
┌──────────┬──────────┬──────────┬──────────┐
│  500     │ 1,000    │ 2,500    │ 5,000    │
│  mesaj   │  mesaj   │  mesaj   │  mesaj   │
│ ₺99,00   │ ₺179,00  │ ₺399,00  │ ₺699,00  │
│          │          │ ⭐ Popüler│          │
│ [Satın Al] [Satın Al] [Satın Al] [Satın Al]│
└──────────┴──────────┴──────────┴──────────┘

📊 İŞLEM GEÇMİŞİ
┌────────┬──────────────┬────────┬─────┬─────┐
│ Tarih  │ İşlem Tipi   │ Miktar │ ... │ ... │
├────────┼──────────────┼────────┼─────┼─────┤
│ 12 Kas │ Manuel Ekleme│ +500   │ ... │ ... │
│ 10 Kas │ Mesaj Gönder │  -50   │ ... │ ... │
└────────┴──────────────┴────────┴─────┴─────┘
```

---

## 🔌 4. Entegrasyon

### A. Mesaj Gönderimi Sırasında Bakiye Kontrolü

**Henüz implement edilmedi - Planlanan:**

```javascript
// Mesaj göndermeden önce
async function sendWhatsAppMessage(clubId, phone, message) {
    // Bakiye kontrolü
    const { data: checkResult } = await supabase.rpc('check_whatsapp_balance', {
        p_club_id: clubId,
        p_message_count: 1
    });
    
    if (!checkResult.has_enough) {
        showAlert('Yetersiz WhatsApp mesaj hakkı! Lütfen paket satın alın.', 'error');
        return false;
    }
    
    // Mesajı gönder
    await sendMessage(phone, message);
    
    // Bakiyeyi azalt
    await supabase.rpc('update_whatsapp_balance', {
        p_club_id: clubId,
        p_amount: -1,
        p_action_type: 'send',
        p_note: `Mesaj gönderildi: ${phone}`
    });
}
```

### B. Toplu Mesaj Gönderimi

```javascript
async function sendBulkMessages(clubId, recipients, message) {
    const messageCount = recipients.length;
    
    // Toplu bakiye kontrolü
    const { data: checkResult } = await supabase.rpc('check_whatsapp_balance', {
        p_club_id: clubId,
        p_message_count: messageCount
    });
    
    if (!checkResult.has_enough) {
        showAlert(`Yetersiz bakiye! ${checkResult.current_balance} mesaj hakkınız var, ${messageCount} mesaj göndermek istiyorsunuz.`, 'error');
        return false;
    }
    
    // Uyarı göster
    if (checkResult.low_balance_warning) {
        showAlert('⚠️ Bakiyeniz düşüyor! Mesaj gönderimi sonrası paket satın almanız önerilir.', 'warning');
    }
    
    // Mesajları gönder
    for (const recipient of recipients) {
        await sendMessage(recipient.phone, message);
    }
    
    // Toplam bakiyeyi azalt
    await supabase.rpc('update_whatsapp_balance', {
        p_club_id: clubId,
        p_amount: -messageCount,
        p_action_type: 'send',
        p_note: `Toplu mesaj: ${messageCount} alıcı`
    });
}
```

---

## ⚠️ 5. Düşük Bakiye Uyarı Sistemi

**Henüz implement edilmedi - Planlanan:**

### Dashboard'da Otomatik Uyarı:

```javascript
async function checkAndShowLowBalanceWarning() {
    const { data: club } = await supabase
        .from('clubs')
        .select('whatsapp_balance')
        .eq('id', currentClubId)
        .single();
    
    const balance = club.whatsapp_balance;
    
    if (balance <= 100) {
        showAlert(`
            <div style="text-align: center;">
                <h3>⚠️ WhatsApp Bakiyeniz Düşük!</h3>
                <p>Sadece <strong>${balance}</strong> mesaj hakkınız kaldı.</p>
                <button onclick="showSection('whatsapp-balance')" class="btn btn-primary">
                    Paket Satın Al
                </button>
            </div>
        `, 'warning', {persistent: true});
    }
}

// Dashboard yüklendiğinde kontrol et
checkAndShowLowBalanceWarning();
```

### Sidebar'da Sürekli Görüntüleme:

```html
<!-- Sidebar'da mevcut -->
<div id="whatsapp-balance-container">
    <span>💬</span>
    <span>Bakiye:</span>
    <span id="whatsapp-balance">2,500</span>
</div>
```

Bakiye güncellemesi:
```javascript
async function updateSidebarBalance() {
    const { data: club } = await supabase
        .from('clubs')
        .select('whatsapp_balance')
        .eq('id', currentClubId)
        .single();
    
    const balanceEl = document.getElementById('whatsapp-balance');
    const containerEl = document.getElementById('whatsapp-balance-container');
    
    if (balanceEl) {
        balanceEl.textContent = club.whatsapp_balance.toLocaleString('tr-TR');
        
        // Düşük bakiyede renk değiştir
        if (club.whatsapp_balance <= 100) {
            containerEl.style.background = 'linear-gradient(135deg, #dc3545 0%, #c82333 100%)';
        }
    }
}
```

---

## 📊 6. Raporlama

### Kulüp İstatistikleri (View):

```sql
SELECT * FROM club_whatsapp_stats WHERE club_id = 'your-club-id';
```

Sonuç:
```
club_id              | kulup_name      | whatsapp_balance | total_sent | total_purchases | total_credits_added | total_credits_used
---------------------|-----------------|------------------|------------|-----------------|---------------------|-------------------
abc-123-def         | Atakum Tenis    | 2450             | 150        | 3               | 3000                | 550
```

### Manuel Sorgular:

```sql
-- En çok mesaj gönderen kulüpler
SELECT 
    c.kulup_name,
    COUNT(*) as message_count,
    SUM(ABS(wbl.amount)) as total_messages
FROM whatsapp_balance_logs wbl
JOIN clubs c ON c.id = wbl.club_id
WHERE wbl.action_type = 'send'
  AND wbl.created_at >= NOW() - INTERVAL '30 days'
GROUP BY c.id, c.kulup_name
ORDER BY total_messages DESC
LIMIT 10;

-- Bakiyesi düşük kulüpler
SELECT 
    kulup_name,
    whatsapp_balance
FROM clubs
WHERE whatsapp_balance < 100
ORDER BY whatsapp_balance ASC;

-- Son 7 günde en çok satılan paketler
SELECT 
    wp.name,
    COUNT(*) as sales_count,
    SUM(wp.message_count) as total_messages_sold
FROM whatsapp_balance_logs wbl
JOIN whatsapp_packages wp ON wp.id = wbl.package_id
WHERE wbl.action_type = 'purchase'
  AND wbl.created_at >= NOW() - INTERVAL '7 days'
GROUP BY wp.id, wp.name
ORDER BY sales_count DESC;
```

---

## 🔒 7. Güvenlik

### RLS Politikaları:

1. **Paketler:** Herkes aktif paketleri görebilir
2. **Loglar:** Kulüpler kendi loglarını görebilir
3. **Bakiye:** Kulüpler kendi bakiyelerini görebilir

### Fonksiyon Güvenliği:

- `update_whatsapp_balance()` → SECURITY DEFINER ile çalışır
- `check_whatsapp_balance()` → SECURITY DEFINER ile çalışır
- Transaction güvenli (bakiye negatif olamaz)

---

## 🐛 8. Sorun Giderme

### Sık Karşılaşılan Hatalar:

#### 1. "Fonksiyon bulunamadı"
```sql
-- Fonksiyonları kontrol edin
SELECT routine_name 
FROM information_schema.routines 
WHERE routine_schema = 'public' 
  AND routine_name LIKE '%whatsapp%';
```

#### 2. "Permission denied"
```sql
-- RLS politikalarını kontrol edin
SELECT * FROM pg_policies WHERE tablename LIKE '%whatsapp%';
```

#### 3. Bakiye güncellenmiyor
```javascript
// Browser console'da kontrol edin
const { data, error } = await supabase.rpc('update_whatsapp_balance', {
    p_club_id: 'your-club-id',
    p_amount: 100,
    p_action_type: 'manual_add'
});
console.log('Result:', data, 'Error:', error);
```

---

## 📞 9. Destek

Sistem kurulumu veya kullanımı ile ilgili sorularınız için:

**Telefon:** 0362 363 00 63

---

## ✅ 10. Kurulum Checklist

- [ ] `whatsapp-credit-system.sql` dosyasını Supabase'de çalıştır
- [ ] Superadmin panelinde "WhatsApp Paketleri" menüsünü kontrol et
- [ ] Örnek paketlerin geldiğini doğrula (5 adet)
- [ ] Bir kulübe test bakiyesi ekle (Kulüpler > Admin Bilgileri)
- [ ] Admin panelinde "WhatsApp Bakiyem" sayfasını aç
- [ ] Paketlerin göründüğünü doğrula
- [ ] İşlem geçmişinin göründüğünü doğrula
- [ ] Sidebar'da bakiye bilgisini kontrol et

---

## 🔮 11. Gelecek Özellikler

1. ✅ **Otomatik Mesaj Gönderim Entegrasyonu**
   - Mesaj gönderildiğinde bakiye otomatik azalsın
   
2. ✅ **Gerçek Zamanlı Uyarılar**
   - Bakiye %10'un altına düştüğünde dashboard'da uyarı
   
3. **Paket Satın Alma Otomasyonu**
   - Online ödeme entegrasyonu
   - Otomatik bakiye yükleme
   
4. **Detaylı Raporlar**
   - Aylık mesaj kullanım grafikleri
   - Maliyet analizi
   - Tahminleme: "Bu kullanımla X gün yeter"
   
5. **Toplu İşlemler**
   - Tüm kulüplere aynı anda bakiye yükleme
   - Toplu paket indirimleri

---

**Son Güncelleme:** 12 Kasım 2025
**Versiyon:** 1.0.0
