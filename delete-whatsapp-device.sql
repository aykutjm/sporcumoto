-- WhatsApp cihazını Supabase'den sil
-- İlk önce hangi cihazlar var görelim:
SELECT 
  id,
  "instanceName",
  "phoneNumber",
  status,
  "createdAt"
FROM "whatsappDevices"
ORDER BY "createdAt" DESC;

-- Silmek için (instanceName'i değiştir):
-- DELETE FROM "whatsappDevices"
-- WHERE "instanceName" = 'CIHAZ_ADI_BURAYA';

-- Örnek:
-- DELETE FROM "whatsappDevices"
-- WHERE "instanceName" = 'Kulup';
