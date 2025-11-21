-- Mevcut settings'deki şablonları message_templates tablosuna migrate et

-- Her kulüp için varsayılan şablonları ekle
INSERT INTO message_templates (club_id, template_name, category, message, is_active, send_days, send_time, days_before)
SELECT 
  c.id as club_id,
  'Cevapsız Arama' as template_name,
  'missed_call' as category,
  'Merhaba,

Size ulaşmaya çalıştık ancak ulaşamadık.

{TARIH} tarihinde bizi aramıştınız.

Sizinle görüşmek ve sorularınızı yanıtlamak isteriz. Lütfen uygun olduğunuzda bizi tekrar arayabilirsiniz.

Teşekkürler,' as message,
  true as is_active,
  ARRAY[1,2,3,4,5] as send_days, -- Pazartesi-Cuma
  '09:00:00'::time as send_time,
  NULL as days_before
FROM clubs c
WHERE NOT EXISTS (
  SELECT 1 FROM message_templates mt 
  WHERE mt.club_id = c.id AND mt.category = 'missed_call'
);

-- Gecikmiş Ödemeler
INSERT INTO message_templates (club_id, template_name, category, message, is_active, send_days, send_time, days_before)
SELECT 
  c.id as club_id,
  'Gecikmiş Ödeme' as template_name,
  'overdue_payment' as category,
  'Sayın {ISIM},

Ödemeniz gecikmiş durumdadır.

En kısa sürede ödemenizi yapmanızı rica ederiz.

Teşekkür ederiz.' as message,
  true as is_active,
  ARRAY[1,2,3,4,5] as send_days,
  '10:00:00'::time as send_time,
  NULL as days_before
FROM clubs c
WHERE NOT EXISTS (
  SELECT 1 FROM message_templates mt 
  WHERE mt.club_id = c.id AND mt.category = 'overdue_payment'
);

-- Devamsızlık
INSERT INTO message_templates (club_id, template_name, category, message, is_active, send_days, send_time, days_before)
SELECT 
  c.id as club_id,
  'Devamsızlık Uyarısı' as template_name,
  'absence' as category,
  'Sayın {ISIM},

{TARIH} tarihindeki derse katılamadığınızı fark ettik.

Umarız her şey yolundadır.

Geçmiş olsun.' as message,
  true as is_active, -- ✅ Aktif
  ARRAY[1,2,3,4,5] as send_days,
  '16:00:00'::time as send_time,
  NULL as days_before
FROM clubs c
WHERE NOT EXISTS (
  SELECT 1 FROM message_templates mt 
  WHERE mt.club_id = c.id AND mt.category = 'absence'
);

-- Yaklaşan Ödemeler
INSERT INTO message_templates (club_id, template_name, category, message, is_active, send_days, send_time, days_before)
SELECT 
  c.id as club_id,
  'Yaklaşan Ödeme' as template_name,
  'upcoming_payment' as category,
  'Sayın {ISIM},

{TARIH} tarihinde ödemeniz bulunmaktadır.

Zamanında ödemenizi hatırlatmak isteriz.

Teşekkür ederiz.' as message,
  true as is_active, -- ✅ Aktif
  ARRAY[1,2,3,4,5] as send_days,
  '10:00:00'::time as send_time,
  2 as days_before -- ✅ 2 gün önceden uyarı (ekran görüntüsündeki gibi)
FROM clubs c
WHERE NOT EXISTS (
  SELECT 1 FROM message_templates mt 
  WHERE mt.club_id = c.id AND mt.category = 'upcoming_payment'
);

-- Deneme Dersi Hatırlatmaları
INSERT INTO message_templates (club_id, template_name, category, message, is_active, send_days, send_time, days_before)
SELECT 
  c.id as club_id,
  'Deneme Dersi Hatırlatma' as template_name,
  'trial_lesson' as category,
  'Merhaba {ISIM},

Deneme dersiniz için sizi bekliyoruz!

📅 Tarih: {TARIH}

Görüşmek üzere!' as message,
  true as is_active, -- ✅ Aktif
  ARRAY[1,2,3,4,5,6,0] as send_days, -- Her gün
  '09:00:00'::time as send_time,
  1 as days_before -- 1 gün önceden (yarın)
FROM clubs c
WHERE NOT EXISTS (
  SELECT 1 FROM message_templates mt 
  WHERE mt.club_id = c.id AND mt.category = 'trial_lesson'
);

-- Sonuç kontrolü
SELECT 
  c.name as club_name,
  COUNT(*) as template_count,
  STRING_AGG(mt.category, ', ') as categories
FROM message_templates mt
JOIN clubs c ON c.id = mt.club_id
GROUP BY c.id, c.name
ORDER BY c.name;
