-- HTTP Extension'ı public schema'dan extensions schema'ya taşı
-- Bu güvenlik uyarısını çözer

-- 1. Extensions schema'yı oluştur (eğer yoksa)
CREATE SCHEMA IF NOT EXISTS extensions;

-- 2. HTTP extension'ı public'ten kaldır
DROP EXTENSION IF EXISTS http CASCADE;

-- 3. HTTP extension'ı extensions schema'ya yükle
CREATE EXTENSION IF NOT EXISTS http
  SCHEMA extensions
  VERSION '1.6';

-- 4. Public kullanıcılarına extensions schema'ya erişim ver
GRANT USAGE ON SCHEMA extensions TO PUBLIC;

-- 5. HTTP fonksiyonlarına erişim izni ver
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA extensions TO PUBLIC;

-- İşlem tamamlandı
SELECT 'HTTP extension başarıyla extensions schema\'ya taşındı!' as status;
