# Supabase Migration Guide - Sporcum CRM

Bu rehber, Firebase'den Supabase'e geçiş sürecini adım adım açıklar.

## 📋 Gereksinimler

1. **Supabase Sunucusu**: Kendi sunucunuzda kurulu Supabase instance
2. **Node.js**: v14 veya üzeri
3. **Firebase Service Account Key**: Firebase'den veri export için gerekli

## 🚀 Adım 1: Supabase Kurulumu

### 1.1 Supabase Sunucunuza Bağlanın

`supabase-config.js` dosyasını düzenleyin:

```javascript
const SUPABASE_CONFIG = {
    url: 'https://your-supabase-server.com',  // Kendi Supabase URL'iniz
    anonKey: 'your-anon-key',                  // Supabase anon key
    serviceRoleKey: 'your-service-role-key'    // Service role key (admin işlemleri için)
};
```

### 1.2 Supabase Database Schema'yı Oluşturun

Supabase SQL Editor'de `supabase-schema.sql` dosyasını çalıştırın:

1. Supabase Dashboard'a gidin
2. SQL Editor'ü açın
3. `supabase-schema.sql` dosyasının içeriğini yapıştırın
4. "Run" butonuna tıklayın

Bu işlem tüm tabloları, indeksleri, triggerlari ve RLS politikalarını oluşturacaktır.

## 📦 Adım 2: Firebase Verilerini Export Etme

### 2.1 Firebase Service Account Key'i İndirin

1. Firebase Console'a gidin: https://console.firebase.google.com
2. Projenizi seçin
3. Project Settings > Service Accounts
4. "Generate New Private Key" butonuna tıklayın
5. İndirilen JSON dosyasını `serviceAccountKey.json` olarak proje klasörüne kaydedin

### 2.2 Dependencies'i Yükleyin

```bash
npm install
```

### 2.3 Export Script'ini Çalıştırın

```bash
node firebase-export.js
```

Bu script:
- Tüm Firebase koleksiyonlarını okur
- Verileri JSON formatında `exports/` klasörüne kaydeder
- Export dosyası: `firebase-export-[timestamp].json`

**ÖNEMLİ**: Bu işlem Firebase'de hiçbir değişiklik yapmaz, sadece okuma işlemi yapar.

## 📥 Adım 3: Supabase'e Import Etme

### 3.1 Supabase Konfigürasyonunu Düzenleyin

`supabase-import.js` dosyasındaki Supabase bilgilerini güncelleyin:

```javascript
const SUPABASE_URL = 'https://your-supabase-server.com';
const SUPABASE_SERVICE_KEY = 'your-service-role-key';
```

### 3.2 Import Script'ini Çalıştırın

```bash
node supabase-import.js
```

Bu script:
- `exports/` klasöründeki en son export dosyasını okur
- Verileri Supabase tablolarına aktarır
- Foreign key constraint'leri dikkate alarak sıralı import yapar

## 🔧 Adım 4: HTML Dosyalarını Güncelleme

### 4.1 Her HTML Dosyasında Firebase'i Supabase ile Değiştirin

Güncellenecek dosyalar:
- `uyeyeni/admin.html`
- `uyeyeni/superadmin.html`
- `uyeyeni/giris.html`
- `uyeyeni/kayit.html`
- `uyeyeni/uye.html`
- `uyeyeni/index.html`
- `uyeyeni/atakumtenis.html` (varsa)

### 4.2 Firebase Script'lerini Kaldırın

**ÖNCE:**
```html
<!-- Firebase -->
<script type="module">
    import { initializeApp } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-app.js";
    import { getAuth } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-auth.js";
    import { getFirestore, collection, addDoc, ... } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-firestore.js";
    
    const firebaseConfig = { ... };
    const app = initializeApp(firebaseConfig);
    const db = getFirestore(app);
    const auth = getAuth(app);
    ...
</script>
```

**SONRA:**
```html
<!-- Supabase -->
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
<script src="supabase-helper.js"></script>
<script type="module">
    // Supabase konfigürasyonu
    const SUPABASE_URL = 'https://your-supabase-server.com';
    const SUPABASE_ANON_KEY = 'your-anon-key';
    
    // Supabase'i başlat
    const supabase = window.supabaseHelper.initSupabase(SUPABASE_URL, SUPABASE_ANON_KEY);
    
    // Auth ve DB nesnelerini global yap (eski kodla uyumluluk için)
    const auth = window.supabaseHelper.auth;
    const db = window.supabaseHelper.db;
    
    // Firebase modüllerini Supabase helper ile değiştir
    window.firebase = {
        collection: db.collection.bind(db),
        addDoc: db.addDoc.bind(db),
        getDocs: db.getDocs.bind(db),
        getDoc: db.getDoc.bind(db),
        updateDoc: db.updateDoc.bind(db),
        deleteDoc: db.deleteDoc.bind(db),
        doc: db.doc.bind(db),
        onSnapshot: db.onSnapshot.bind(db),
        query: db.query.bind(db),
        where: window.supabaseHelper.where,
        orderBy: window.supabaseHelper.orderBy,
        limit: window.supabaseHelper.limit,
        arrayUnion: window.supabaseHelper.arrayUnion,
        arrayRemove: window.supabaseHelper.arrayRemove,
        setDoc: db.setDoc.bind(db)
    };
    
    window.db = db;
    window.auth = auth;
</script>
```

### 4.3 Koleksiyon İsimlerini Güncelle

Firebase koleksiyon isimleri camelCase, Supabase tablo isimleri snake_case:

```javascript
// Firebase
'preRegistrations' → 'pre_registrations'
'whatsappDevices' → 'whatsapp_devices'
'crmLeads' → 'crm_leads'
// ... diğerleri
```

`supabase-helper.js` bu dönüşümü otomatik yapıyor, ancak bazı yerlerde manuel güncelleme gerekebilir.

## 🔐 Adım 5: Authentication Güncellemeleri

### 5.1 Kullanıcı Kaydı

**Firebase:**
```javascript
await createUserWithEmailAndPassword(auth, email, password);
```

**Supabase:**
```javascript
await auth.signUp(email, password);
```

### 5.2 Kullanıcı Girişi

**Firebase:**
```javascript
await signInWithEmailAndPassword(auth, email, password);
```

**Supabase:**
```javascript
await auth.signInWithEmailAndPassword(email, password);
```

`supabase-helper.js` bu uyumluluğu sağlıyor.

## 📊 Adım 6: Subcollection'ları Güncelleme

Firebase'de subcollection'lar vardı (örn: `clubs/{clubId}/crmTags`), Supabase'de bunları normal tablolar olarak club_id ile bağlıyoruz:

```javascript
// Firebase
const tagsRef = collection(db, `clubs/${clubId}/crmTags`);

// Supabase
const tagsRef = db.collection('crm_tags');
// Query with club_id filter
const { data } = await supabase
    .from('crm_tags')
    .select('*')
    .eq('club_id', clubId);
```

## 🧪 Adım 7: Test Etme

### 7.1 Temel Testler

1. **Giriş Yapma**: `giris.html` sayfasından giriş yapın
2. **Dashboard**: Ana sayfada verilerin yüklendiğini kontrol edin
3. **CRUD İşlemleri**:
   - Yeni üye ekleme
   - Üye düzenleme
   - Üye silme
4. **CRM İşlemleri**:
   - Lead ekleme
   - Lead durumu güncelleme
5. **WhatsApp Entegrasyonu**:
   - Mesaj gönderme
   - Gelen aramalar

### 7.2 Performance Testi

- Büyük veri setleriyle sayfalama testleri
- Real-time güncellemeleri test edin

## 🔄 Adım 8: Realtime Features

Supabase realtime özellikleri için:

```javascript
// Subscribe to changes
const subscription = supabase
    .channel('members-changes')
    .on('postgres_changes', 
        { event: '*', schema: 'public', table: 'members' },
        (payload) => {
            console.log('Change received!', payload);
            // Verileri yeniden yükle
        }
    )
    .subscribe();

// Unsubscribe when done
subscription.unsubscribe();
```

## ⚠️ Önemli Notlar

1. **Firebase'e Dokunmuyoruz**: Tüm süreç boyunca Firebase veritabanında hiçbir değişiklik yapmıyoruz
2. **İki Ayrı Sistem**: Firebase ve Supabase versiyonları bağımsız çalışacak
3. **Data Migration**: Export/Import işlemi tek seferlik yapılır
4. **Auth Migration**: Kullanıcıların Supabase'de yeniden kayıt olması gerekebilir (şifreler export edilemez)
5. **Field Names**: Otomatik dönüşüm (camelCase ↔ snake_case) `supabase-helper.js` tarafından yapılıyor

## 📝 Checklist

- [ ] Supabase sunucusu hazır
- [ ] `supabase-schema.sql` çalıştırıldı
- [ ] `serviceAccountKey.json` Firebase'den indirildi
- [ ] `npm install` yapıldı
- [ ] `node firebase-export.js` çalıştırıldı
- [ ] `supabase-import.js` dosyası konfigüre edildi
- [ ] `node supabase-import.js` çalıştırıldı
- [ ] `admin.html` güncellendi
- [ ] `superadmin.html` güncellendi
- [ ] `giris.html` güncellendi
- [ ] `kayit.html` güncellendi
- [ ] `uye.html` güncellendi
- [ ] `index.html` güncellendi
- [ ] Tüm HTML dosyalarında Supabase config eklendi
- [ ] Test edildi

## 🆘 Sorun Giderme

### Hata: "relation does not exist"
- SQL schema'nın tam olarak çalıştırıldığından emin olun
- Tablo isimlerinin doğru olduğunu kontrol edin

### Hata: "permission denied"
- RLS politikalarını kontrol edin
- Service role key kullandığınızdan emin olun (import için)

### Veri Görünmüyor
- Browser console'da hata kontrol edin
- Network tab'da Supabase request'leri kontrol edin
- club_id filter'larının doğru uygulandığını kontrol edin

### Auth Sorunları
- Supabase Authentication ayarlarını kontrol edin
- Email confirmation disabled yapın (geliştirme için)

## 📞 Destek

Herhangi bir sorun yaşarsanız:
1. Browser console'u kontrol edin
2. Supabase Dashboard > Logs kontrol edin
3. `supabase-helper.js` debug mode'u aktif edin

## 🎉 Migration Tamamlandı!

Başarıyla migration tamamlandıktan sonra:
- Firebase versiyonu `uyekayit-5964b` Firebase projesinde çalışmaya devam eder
- Supabase versiyonu kendi sunucunuzdaki Supabase'de çalışır
- Her iki sistem birbirinden bağımsızdır

