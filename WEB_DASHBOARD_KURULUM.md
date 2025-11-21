# 🚀 Supabase Edge Function - WEB DASHBOARD İLE KURULUM

Supabase CLI kurmadan, doğrudan Dashboard'dan Edge Function oluşturacağız.

---

## ADIM 1: Edge Function Oluştur

1. **Supabase Dashboard** açın: https://supabase.com/dashboard
2. Projenizi seçin
3. Sol menüden **Edge Functions** tıklayın
4. **Create a new function** butonuna tıklayın
5. Function name: `auto-reply-missed-calls`
6. **Create function** tıklayın

---

## ADIM 2: Kodu Yapıştır

1. Editor açılacak, aşağıdaki kodu tamamen silin ve yerine şunu yapıştırın:

```typescript
// DOSYA: supabase/functions/auto-reply-missed-calls/index.ts
// İçeriği kopyalayın ve yapıştırın
```

**Dosya konumu:** `c:\Users\adnan\Desktop\Projeler\sporcum-supabase\supabase\functions\auto-reply-missed-calls\index.ts`

2. **Deploy** butonuna tıklayın

---

## ADIM 3: Veritabanı Tablosunu Oluştur

1. Sol menüden **SQL Editor** tıklayın
2. **New query** tıklayın
3. Aşağıdaki dosyanın içeriğini yapıştırın:

**Dosya:** `c:\Users\adnan\Desktop\Projeler\sporcum-supabase\create-autoReplySent-table.sql`

4. **Run** tıklayın (veya Ctrl+Enter)

---

## ADIM 4: Cron Job Kur (OTOMATİK ÇALIŞTIRMA)

1. **Database > Extensions** tıklayın
2. `pg_cron` extension'ı **ENABLE** edin
3. **SQL Editor**'e geri dönün
4. Şu kodu çalıştırın:

```sql
-- Her 2 dakikada bir otomatik çalıştır
SELECT cron.schedule(
  'auto-reply-missed-calls',
  '*/2 * * * *', -- Her 2 dakika
  $$
  SELECT
    net.http_post(
      url:='https://YOUR_PROJECT_ID.supabase.co/functions/v1/auto-reply-missed-calls',
      headers:='{"Content-Type": "application/json", "Authorization": "Bearer YOUR_ANON_KEY"}'::jsonb,
      body:='{}'::jsonb
    ) as request_id;
  $$
);
```

**ÖNEMLİ:** Değiştirmeniz gerekenler:

- `YOUR_PROJECT_ID` → **Settings > General > Reference ID** (örn: `abcdefgh1234567`)
- `YOUR_ANON_KEY` → **Settings > API > anon public key** (uzun bir token)

5. **Run** tıklayın

---

## ADIM 5: Test Et

1. **Edge Functions** sayfasına geri dönün
2. `auto-reply-missed-calls` fonksiyonunu seçin
3. **Invoke Function** butonuna tıklayın
4. Response'da şunu görmelisiniz:

```json
{
  "success": true,
  "totalMessagesSent": 0,
  "timestamp": "2025-11-20T..."
}
```

---

## ✅ KONTROL LİSTESİ

- [ ] Edge Function oluşturuldu
- [ ] Kod yapıştırıldı ve deploy edildi
- [ ] `autoReplySent` tablosu oluşturuldu
- [ ] `pg_cron` extension enable edildi
- [ ] Cron job oluşturuldu (YOUR_PROJECT_ID ve YOUR_ANON_KEY değiştirildi)
- [ ] Manuel test yapıldı

---

## 🔍 SORUN GİDERME

### Edge Function Çalışmıyor

1. **Logs** sekmesine tıklayın
2. Hataları kontrol edin
3. En yaygın hata: Bulutfon API Key eksik
   - `clubs` tablosunda `settings.bulutfonApiKey` olmalı

### Cron Job Çalışmıyor

```sql
-- Cron job'ları listele
SELECT * FROM cron.job;

-- Çalışma geçmişi
SELECT * FROM cron.job_run_details ORDER BY start_time DESC LIMIT 10;
```

### Test Sırasında Hata

- `whatsappDevices` tablosunda aktif cihaz var mı kontrol edin
- `clubs` tablosunda `settings.bulutfonApiKey` var mı kontrol edin

---

## 📊 SONUÇ

✅ Edge Function her 2 dakikada otomatik çalışacak  
✅ Sayfa kapalı olsa bile mesajlar gönderilecek  
✅ Mesai saatleri kontrolü yapılacak  
✅ Duplicate mesaj engelleme çalışacak  

**Tamamdır!** 🎉
