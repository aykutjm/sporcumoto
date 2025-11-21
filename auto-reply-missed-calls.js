// Auto-Reply to Missed Calls - Node.js Version
// Kendi sunucunuzda çalışır

require('dotenv').config();
const { createClient } = require('@supabase/supabase-js');

// Node.js v18+ built-in fetch kullan, yoksa node-fetch'i import et
const fetch = globalThis.fetch || require('node-fetch');

const BULUTFON_API_URL = 'https://api.bulutfon.com';

// Supabase ayarları (environment variables'dan al)
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!SUPABASE_URL || !SUPABASE_SERVICE_KEY) {
  console.error('❌ HATA: .env dosyasında SUPABASE_URL ve SUPABASE_SERVICE_ROLE_KEY tanımlı değil!');
  console.error('   .env.example dosyasını kopyalayıp .env olarak kaydedin ve değerleri doldurun.');
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

async function main() {
  try {
    console.log('🚀 Auto-reply script başlatıldı:', new Date().toLocaleString('tr-TR'));

    // Tüm aktif kulüpleri al
    const { data: clubs, error: clubsError } = await supabase
      .from('clubs')
      .select('id')
      .eq('active', true);

    if (clubsError) throw clubsError;

    console.log(`📊 ${clubs?.length || 0} aktif kulüp bulundu`);

    let totalMessagesSent = 0;

    // Her kulüp için kontrol yap
    for (const club of clubs || []) {
      const clubId = club.id;
      
      // settings tablosundan ayarları al (data kolonu JSONB)
      // NOT: Birden fazla kayıt olabilir, en güncel olanı al
      const { data: settingsRecords, error: settingsError } = await supabase
        .from('settings')
        .select('data')
        .eq('clubId', clubId)
        .order('updatedAt', { ascending: false })
        .limit(1);
      
      const settings = settingsRecords?.[0]?.data || {};

      console.log(`\n🏢 Kulüp kontrol ediliyor: ${clubId}`);

      // Bulutfon API Key kontrolü
      if (!settings.bulutfonApiKey) {
        console.log(`  ⏭️ Bulutfon API key yok, atlanıyor`);
        continue;
      }

      // WhatsApp cihazlarını al
      const { data: devices, error: devicesError } = await supabase
        .from('whatsappDevices')
        .select('*')
        .eq('clubId', clubId)
        .eq('status', 'active');

      if (devicesError || !devices || devices.length === 0) {
        console.log(`  ⏭️ WhatsApp cihazı yok, atlanıyor`);
        continue;
      }

      console.log(`  ✅ ${devices.length} WhatsApp cihazı bulundu`);

      // Bulutfon'dan cevapsız çağrıları al
      const missedCalls = await fetchMissedCalls(settings.bulutfonApiKey);
      
      if (!missedCalls || missedCalls.length === 0) {
        console.log(`  📞 Cevapsız çağrı yok`);
        continue;
      }

      console.log(`  📞 ${missedCalls.length} cevapsız çağrı bulundu`);

      // Bugün gönderilen mesajları al (duplicate kontrolü - telefon + template)
      const today = new Date().toISOString().split('T')[0];
      const { data: sentToday, error: sentError } = await supabase
        .from('autoReplySent')
        .select('phone, templateType')
        .eq('clubId', clubId)
        .gte('sentDate', `${today}T00:00:00.000Z`)
        .lt('sentDate', `${today}T23:59:59.999Z`);

      // Telefon + şablon kombinasyonu için Set oluştur (örn: "05551234567_incoming-missed-call-template")
      const sentCombinations = new Set((sentToday || []).map(s => `${s.phone}_${s.templateType || 'incoming-missed-call-template'}`));

      // CRM mesaj şablonunu al
      const { data: templates, error: templatesError } = await supabase
        .from('messageTemplates')
        .select('templates')
        .eq('clubId', clubId)
        .single();

      const messageTemplate = templates?.templates?.['incoming-missed-call-template']?.message || 
        'Merhaba,\n\nBizi {TARIH} tarihinde aramaya çalıştınız ancak o anda yoğunluktan dolayı telefonunuzu açamadık.\n\nSize nasıl yardımcı olabiliriz?\n\nLütfen bizi tekrar arayabilir veya mesajınızı buradan iletebilirsiniz.\n\nTeşekkürler';

      const templateType = 'incoming-missed-call-template';

      // Her cevapsız çağrı için işle
      for (const call of missedCalls) {
        const caller = call.caller.replace(/\D/g, '');
        const callee = call.callee.replace(/\D/g, '');

        // *** 1. MESAJ GÖNDERİM SAATİ KONTROLÜ (messageSendingHours) ***
        // Mesai saati dışında hiç mesaj gitmesin
        if (settings.messageSendingHours?.enabled) {
          const isSendingHours = checkMessageSendingHours(call.call_time, settings.messageSendingHours);
          if (!isSendingHours) {
            console.log(`  ⏰ ${caller} - Mesaj gönderim saati dışında aranmış, mesaj gönderilmeyecek`);
            continue;
          }
        }

        // *** 2. DUPLICATE KONTROLÜ (aynı gün + aynı telefon + aynı şablon) ***
        const combinationKey = `${caller}_${templateType}`;
        if (sentCombinations.has(combinationKey)) {
          console.log(`  ⏭️ ${caller} - Bugün aynı CRM şablonu zaten gönderildi`);
          continue;
        }

        // Eşleşen WhatsApp cihazını bul
        const device = findMatchingDevice(callee, devices);
        if (!device) {
          console.log(`  ⚠️ ${callee} için WhatsApp cihazı bulunamadı`);
          continue;
        }

        // Telefon numarasını formatla
        let formattedCaller = caller;
        if (caller.startsWith('90') && caller.length === 12) {
          formattedCaller = '0' + caller.slice(2);
        } else if (!caller.startsWith('0') && caller.length === 10) {
          formattedCaller = '0' + caller;
        }

        // Mesaj metnini oluştur - Tarihi Türkçe formatla
        let formattedDate = call.call_time;
        try {
          const callDate = new Date(call.call_time);
          const day = String(callDate.getDate()).padStart(2, '0');
          const month = String(callDate.getMonth() + 1).padStart(2, '0');
          const year = callDate.getFullYear();
          const hours = String(callDate.getHours()).padStart(2, '0');
          const minutes = String(callDate.getMinutes()).padStart(2, '0');
          formattedDate = `${day}.${month}.${year} ${hours}:${minutes}`;
        } catch (e) {
          console.log('  ⚠️ Tarih formatlanamadı:', e);
        }
        
        const finalMessage = messageTemplate.replace(/{TARIH}/g, formattedDate);

        // Mesajı kuyruğa ekle
        await supabase
          .from('messageQueue')
          .insert({
            id: crypto.randomUUID(),
            clubId,
            phone: formattedCaller,
            message: finalMessage,
            deviceId: device.instanceName,
            scheduledFor: new Date().toISOString(),
            status: 'pending',
            createdAt: new Date().toISOString(),
            createdBy: 'Node.js Script (Otomatik)',
            type: 'auto_reply_missed_call'
          });

        // Gönderim kaydı oluştur (template bilgisi ile)
        await supabase
          .from('autoReplySent')
          .insert({
            clubId,
            phone: caller,
            formattedPhone: formattedCaller,
            templateType: templateType, // Şablon türünü kaydet
            sentDate: new Date().toISOString(),
            callTime: call.call_time,
            deviceUsed: device.instanceName
          });

        console.log(`  ✅ Mesaj kuyruğa eklendi: ${formattedCaller} (${device.instanceName})`);
        totalMessagesSent++;
      }
    }

    console.log(`\n✅ İşlem tamamlandı: ${totalMessagesSent} mesaj kuyruğa eklendi`);
    console.log(`⏰ Bitiş: ${new Date().toLocaleString('tr-TR')}\n`);

  } catch (error) {
    console.error('❌ Hata:', error.message);
    process.exit(1);
  }
}

// Bulutfon'dan cevapsız çağrıları al
async function fetchMissedCalls(apiKey) {
  try {
    // Firebase Cloud Function proxy kullan (admin.html'deki gibi)
    const response = await fetch(`https://us-central1-uyekayit-5964b.cloudfunctions.net/bulutfonProxy?apikey=${apiKey}`, {
      method: 'GET',
      headers: { 'Content-Type': 'application/json' }
    });

    if (!response.ok) {
      console.error('Bulutfon API error:', response.status);
      return [];
    }

    const data = await response.json();
    const allRecords = Array.isArray(data) ? data : (data.cdrs || data.data || []);
    
    // Cevapsız çağrıları filtrele (son 10 dakika, gelen aramalar, cevapsız)
    const tenMinutesAgo = new Date(Date.now() - 10 * 60 * 1000);
    
    return allRecords.filter((call) => {
      if (call.direction !== 'IN') return false;
      
      const callDate = new Date(call.call_time);
      if (callDate <= tenMinutesAgo) return false;
      
      // is_missing_call parametresi varsa kullan
      if (call.is_missing_call !== undefined && call.is_missing_call !== null) {
        const isMissing = call.is_missing_call === true || call.is_missing_call === "true" || call.is_missing_call === 1;
        return isMissing;
      }
      
      // Fallback: hangup_cause kontrol et
      const hangupCause = (call.hangup_cause || '').toUpperCase();
      return hangupCause !== 'ANSWERED';
    });
  } catch (error) {
    console.error('Bulutfon fetch error:', error);
    return [];
  }
}

// Mesaj Gönderim Saati kontrolü (messageSendingHours)
function checkMessageSendingHours(callTime, messageSendingHours) {
  const callDate = new Date(callTime);
  const callHour = callDate.getHours();
  const callMinute = callDate.getMinutes();
  const callDay = callDate.getDay();

  const [startHour, startMin] = (messageSendingHours.start || '09:00').split(':').map(Number);
  const [endHour, endMin] = (messageSendingHours.end || '18:00').split(':').map(Number);

  // Mesaj gönderim günü kontrolü
  const sendDays = messageSendingHours.days || [1, 2, 3, 4, 5];
  if (!sendDays.includes(callDay)) {
    return false;
  }

  // Saat kontrolü
  const callTimeInMinutes = callHour * 60 + callMinute;
  const startTimeInMinutes = startHour * 60 + startMin;
  const endTimeInMinutes = endHour * 60 + endMin;

  return callTimeInMinutes >= startTimeInMinutes && callTimeInMinutes < endTimeInMinutes;
}

// Çalışma saati kontrolü (eski - artık kullanılmıyor)
function checkWorkingHours(callTime, settings) {
  const callDate = new Date(callTime);
  const callHour = callDate.getHours();
  const callMinute = callDate.getMinutes();
  const callDay = callDate.getDay();

  const [startHour, startMin] = (settings.workingHoursStart || '09:00').split(':').map(Number);
  const [endHour, endMin] = (settings.workingHoursEnd || '18:00').split(':').map(Number);

  // Çalışma günü kontrolü
  const workDays = settings.workingDays || [1, 2, 3, 4, 5];
  if (!workDays.includes(callDay)) {
    return false;
  }

  // Saat kontrolü
  const callTimeInMinutes = callHour * 60 + callMinute;
  const startTimeInMinutes = startHour * 60 + startMin;
  const endTimeInMinutes = endHour * 60 + endMin;

  return callTimeInMinutes >= startTimeInMinutes && callTimeInMinutes < endTimeInMinutes;
}

// WhatsApp cihazı eşleştir
function findMatchingDevice(callee, devices) {
  const calleeLast10 = callee.slice(-10);
  
  for (const device of devices) {
    const devicePhone = device.phoneNumber.replace(/\D/g, '');
    const deviceLast10 = devicePhone.slice(-10);
    
    if (deviceLast10 === calleeLast10) {
      return device;
    }
  }
  
  return null;
}

// Script'i çalıştır
main();
