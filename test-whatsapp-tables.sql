-- 🧪 TEST: TABLO İŞLEMLERİNİ DENE
-- Bu SQL'i Supabase SQL Editor'de çalıştırarak tabloların çalıştığını test edin

-- ⚠️ NOT: Gerçek bir clubId kullanın (örnek: 'atakumtenis')
-- currentClubId'yi kendi club_id'niz ile değiştirin

-- 1️⃣ Test çağrısı ekle
INSERT INTO whatsapp_incoming_calls (
    club_id,
    caller_phone,
    caller_name,
    called_number,
    instance_name,
    call_status,
    is_video,
    is_missing_call
) VALUES (
    'TEST_CLUB_ID',  -- ⚠️ Gerçek clubId yazın
    '905551234567',
    'Test Arayan',
    '905559876543',
    'test-instance',
    'missed',
    false,
    true
) RETURNING *;

-- 2️⃣ Test mesajı ekle
INSERT INTO whatsapp_incoming_messages (
    club_id,
    remote_jid,
    push_name,
    instance_name,
    message_content,
    message_key
) VALUES (
    'TEST_CLUB_ID',  -- ⚠️ Gerçek clubId yazın
    '905551234567@s.whatsapp.net',
    'Test Gönderen',
    'test-instance',
    '{"conversation": "Test mesajı"}',
    '{"id": "test123", "fromMe": false, "remoteJid": "905551234567@s.whatsapp.net"}'
) RETURNING *;

-- 3️⃣ Eklenen kayıtları görüntüle
SELECT * FROM whatsapp_incoming_calls 
WHERE club_id = 'TEST_CLUB_ID'  -- ⚠️ Gerçek clubId yazın
ORDER BY call_timestamp DESC 
LIMIT 5;

SELECT * FROM whatsapp_incoming_messages 
WHERE club_id = 'TEST_CLUB_ID'  -- ⚠️ Gerçek clubId yazın
ORDER BY message_timestamp DESC 
LIMIT 5;

-- 4️⃣ Test verilerini temizle (isteğe bağlı)
-- DELETE FROM whatsapp_incoming_calls WHERE club_id = 'TEST_CLUB_ID';
-- DELETE FROM whatsapp_incoming_messages WHERE club_id = 'TEST_CLUB_ID';
