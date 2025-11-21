-- 🎂 DOĞUM GÜNÜ ŞABLONU EKLEME
-- messageTemplates kaydına birthday şablonunu ekle

UPDATE settings
SET data = jsonb_set(
    COALESCE(data::jsonb, '{}'::jsonb),
    '{birthday}',
    '{
        "textChild": "Sayın {UYE_AD_SOYAD},\\n\\nTenisçimiz {OGRENCI_AD_SOYAD}''nın doğum gününü en içten dileklerimizle kutlarız! 🎂🎾\\n\\nNice mutlu, sağlıklı ve başarılı yıllar dileriz.",
        "textAdult": "Sayın {UYE_AD_SOYAD},\\n\\nDoğum gününüzü en içten dileklerimizle kutlarız! 🎂🎾\\n\\nNice mutlu, sağlıklı ve başarılı yıllar dileriz.",
        "enabled": false
    }'::jsonb
)::json
WHERE id = 'messageTemplates_FevoFvTCek44CR3pS4XC';

-- ✅ Kontrol et
SELECT id, data FROM settings WHERE id = 'messageTemplates_FevoFvTCek44CR3pS4XC';

-- 📋 SONUÇ:
-- data kolonunda artık birthday objesi olmalı:
-- {
--   "birthday": {
--     "textChild": "...",
--     "textAdult": "...",
--     "enabled": false
--   }
-- }

-- 🎯 SONRAKİ ADIM:
-- Admin panelde Ayarlar → Mesaj Şablonları → Doğum Günü checkbox'ını işaretle → Kaydet
-- Böylece enabled: true olacak
