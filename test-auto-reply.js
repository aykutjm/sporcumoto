// Manuel Test - Mock Bulutfon Data ile
require('dotenv').config();
const { createClient } = require('@supabase/supabase-js');

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;
const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

// Admin.html'den gördüğümüz gerçek cevapsız arama örneği
const mockMissedCall = {
  uuid: 'a672cbb8-0ffa-40e0-93ba-bc0e46d1ede7',
  call_type: 'voice',
  direction: 'IN',
  caller: '905355087586',
  callee: '903623630064',
  call_time: new Date().toISOString()
};

async function testAutoReply() {
  console.log('🧪 AUTO-REPLY TEST (Mock Data)\n');
  
  const clubId = 'FmvoFvTCek44CR3pS4XC';
  const caller = mockMissedCall.caller.replace(/\D/g, '');
  const callee = mockMissedCall.callee.replace(/\D/g, '');
  
  console.log('📞 Cevapsız Arama:');
  console.log('   Arayan:', caller);
  console.log('   Aranan:', callee);
  
  // WhatsApp cihazını bul
  const { data: devices, error } = await supabase
    .from('whatsappDevices')
    .select('*')
    .eq('clubId', clubId)
    .eq('status', 'active');
  
  if (error) {
    console.error('❌ Cihaz sorgusu hatası:', error);
    return;
  }
  
  console.log('\n📱 WhatsApp Cihazları:', devices?.length);
  
  if (!devices || devices.length === 0) {
    console.log('❌ Cihaz bulunamadı!');
    return;
  }
  
  // Eşleşen cihazı bul
  const calleeLast10 = callee.slice(-10);
  const device = devices.find(d => {
    const devicePhone = d.phoneNumber.replace(/\D/g, '');
    const deviceLast10 = devicePhone.slice(-10);
    return deviceLast10 === calleeLast10;
  });
  
  if (!device) {
    console.log('❌ Eşleşen cihaz bulunamadı!');
    console.log('   Aranan son 10:', calleeLast10);
    devices.forEach(d => {
      const dLast10 = d.phoneNumber.replace(/\D/g, '').slice(-10);
      console.log('   Cihaz son 10:', dLast10, '-', d.instanceName);
    });
    return;
  }
  
  console.log('✅ Eşleşen cihaz:', device.instanceName);
  
  // Telefon formatla
  let formattedCaller = caller;
  if (caller.startsWith('90') && caller.length === 12) {
    formattedCaller = '0' + caller.slice(2);
  } else if (!caller.startsWith('0') && caller.length === 10) {
    formattedCaller = '0' + caller;
  }
  
  console.log('   Format:', formattedCaller);
  
  // Tarih formatla
  const callDate = new Date(mockMissedCall.call_time);
  const day = String(callDate.getDate()).padStart(2, '0');
  const month = String(callDate.getMonth() + 1).padStart(2, '0');
  const year = callDate.getFullYear();
  const hours = String(callDate.getHours()).padStart(2, '0');
  const minutes = String(callDate.getMinutes()).padStart(2, '0');
  const formattedDate = `${day}.${month}.${year} ${hours}:${minutes}`;
  
  const message = `Merhaba,\n\nBizi ${formattedDate} tarihinde aramaya çalıştınız ancak o anda yoğunluktan dolayı telefonunuzu açamadık.\n\nSize nasıl yardımcı olabiliriz?\n\nLütfen bizi tekrar arayabilir veya mesajınızı buradan iletebilirsiniz.\n\nTeşekkürler`;
  
  console.log('\n📝 Mesaj:');
  console.log(message);
  
  // Mesajı kuyruğa ekle
  console.log('\n💾 Mesajı kuyruğa ekleniyor...');
  
  const { data: queueData, error: queueError } = await supabase
    .from('messageQueue')
    .insert({
      id: crypto.randomUUID(),
      clubId,
      phone: formattedCaller,
      message: message,
      deviceId: device.instanceName,
      scheduledFor: new Date().toISOString(),
      status: 'pending',
      createdAt: new Date().toISOString(),
      createdBy: 'Auto-Reply Test',
      type: 'auto_reply_missed_call'
    })
    .select();
  
  if (queueError) {
    console.error('❌ Kuyruk hatası:', queueError);
    return;
  }
  
  console.log('✅ Mesaj kuyruğa eklendi!');
  console.log('   Kuyruk ID:', queueData?.[0]?.id);
  
  // autoReplySent tablosuna kaydet
  const { error: sentError } = await supabase
    .from('autoReplySent')
    .insert({
      clubId,
      phone: caller,
      formattedPhone: formattedCaller,
      sentDate: new Date().toISOString(),
      callTime: mockMissedCall.call_time,
      deviceUsed: device.instanceName
    });
  
  if (sentError) {
    console.error('❌ autoReplySent hatası:', sentError);
  } else {
    console.log('✅ autoReplySent kaydı oluşturuldu');
  }
  
  console.log('\n🎉 TEST BAŞARILI!');
}

testAutoReply().catch(console.error);
