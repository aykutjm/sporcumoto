# WhatsApp Bakiye Azaltma Düzeltmesi

## 🔧 Yapılan Değişiklikler

### 1. **Tek Mesaj Gönderme** (`admin.html` satır ~6297)
- Mesaj başarıyla gönderildikten sonra `update_whatsapp_balance()` fonksiyonu çağrılıyor
- Her mesaj için bakiye `-1` azaltılıyor
- İşlem `whatsapp_balance_logs` tablosuna kaydediliyor

### 2. **Toplu/Otomatik Mesaj Gönderme** (`sendWhatsAppMessage` fonksiyonu)
- **Mesaj göndermeden ÖNCE:** `check_whatsapp_balance()` ile bakiye kontrolü
- **Yetersiz bakiye durumunda:** Mesaj gönderilmiyor, kullanıcıya uyarı gösteriliyor
- **Düşük bakiye uyarısı:** Bakiye 100'ün altına düştüğünde uyarı
- **Mesaj başarıyla gönderildikten SONRA:** Bakiye otomatik azaltılıyor

## 📊 Kullanılan Supabase Fonksiyonlar

### `update_whatsapp_balance()`
```sql
-- Parametreler:
p_club_id TEXT,           -- Kulüp ID
p_amount INTEGER,         -- Miktar (-1 mesaj göndermek için)
p_action_type VARCHAR,    -- 'send', 'add', 'purchase' vb.
p_note TEXT,             -- İşlem notu
p_created_by VARCHAR     -- İşlemi yapan kullanıcı
```

### `check_whatsapp_balance()`
```sql
-- Parametreler:
p_club_id TEXT,          -- Kulüp ID
p_message_count INTEGER  -- Gönderilecek mesaj sayısı (varsayılan: 1)

-- Döndürülen JSON:
{
  "has_enough": true/false,
  "current_balance": 150,
  "requested": 1,
  "remaining_after": 149,
  "low_balance_warning": false
}
```

## ✅ Test Adımları

1. **Bakiye Kontrolü**
   ```javascript
   // Console'da çalıştırın
   const { data, error } = await supabaseClient
       .from('clubs')
       .select('whatsapp_balance')
       .eq('id', currentClubId)
       .single();
   console.log('Mevcut bakiye:', data.whatsapp_balance);
   ```

2. **Tek Mesaj Testi**
   - WhatsApp sekmesinden bir kişiye mesaj gönderin
   - Console'da "💰 Bakiye güncellendi" logunu görmelisiniz
   - Bakiye 1 azalmalı

3. **Toplu Mesaj Testi**
   - Toplu Mesaj sekmesinden 2-3 kişi seçin
   - Mesaj gönderin
   - Her mesaj için bakiye 1'er azalmalı

4. **Yetersiz Bakiye Testi**
   ```javascript
   // Bakiyeyi 0'a çekin (sadece test için!)
   await supabaseClient.rpc('update_whatsapp_balance', {
       p_club_id: currentClubId,
       p_amount: -999999, // Bakiyeyi sıfırla
       p_action_type: 'manual_add',
       p_note: 'Test için bakiye sıfırlandı',
       p_created_by: currentUser.email
   });
   ```
   - Şimdi mesaj göndermeyi deneyin
   - "❌ Mesaj bakiyeniz tükendi!" uyarısı görmelisiniz

5. **İşlem Geçmişi Kontrolü**
   ```javascript
   // Son 10 işlemi görün
   const { data: logs } = await supabaseClient
       .from('whatsapp_balance_logs')
       .select('*')
       .eq('club_id', currentClubId)
       .order('created_at', { ascending: false })
       .limit(10);
   console.table(logs);
   ```

## 🔄 Bakiye Yükleme

Bakiye panelinde "Bakiye Yükle" butonundan paket satın alınabilir. Manuel bakiye eklemek için:

```javascript
// Console'dan manuel bakiye ekleme
const { data, error } = await supabaseClient.rpc('update_whatsapp_balance', {
    p_club_id: currentClubId,
    p_amount: 1000, // Eklenecek miktar
    p_action_type: 'manual_add',
    p_note: 'Manuel bakiye eklendi',
    p_created_by: currentUser.email
});

console.log('Yeni bakiye:', data);
```

## 🐛 Sorun Giderme

### Bakiye azalmıyorsa:
1. Console'da hata var mı kontrol edin
2. `whatsapp-credit-system.sql` dosyasının Supabase'de çalıştırılıp çalıştırılmadığını kontrol edin
3. RLS (Row Level Security) politikalarını kontrol edin

### Mesaj gönderilmiyor ama bakiye azaldıysa:
- Bu normalde mümkün değil çünkü bakiye sadece `response.ok` durumunda azaltılıyor
- Eğer böyle bir durum varsa, logs tablosunu kontrol edin:
  ```sql
  SELECT * FROM whatsapp_balance_logs 
  WHERE club_id = 'CLUB_ID_BURAYA' 
  ORDER BY created_at DESC;
  ```

## 📝 Notlar

- Bakiye sistem tarafında (Supabase) tutulur, güvenlik için RLS politikaları aktiftir
- Her mesaj gönderimi `whatsapp_balance_logs` tablosuna kaydedilir (audit trail)
- Toplu mesajlarda bakiye tükenirse, kalan mesajlar gönderilmez
- İşlem geçmişi WhatsApp Ayarları sekmesinde "İşlem Geçmişi" butonundan görülebilir
