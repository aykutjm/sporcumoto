-- whatsappDevices tablosunu kontrol et
SELECT 
  wd.id,
  wd.device_name,
  wd.club_id,
  wd.phone_number,
  wd.message_sending_hours -- Bu kolon var mı?
FROM whatsapp_devices wd
LIMIT 3;
