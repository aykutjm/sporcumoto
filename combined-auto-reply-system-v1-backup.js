// Birleşik Otomatik Cevap Sistemi
// 1. Cevapsız aramaları kontrol edip kuyruğa ekler
// 2. Kuyruktaki mesajları WhatsApp'a gönderir

import { createClient } from '@supabase/supabase-js';
import 'dotenv/config';
import crypto from 'crypto';

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_KEY
);

// ==================== PART 1: CEVAPSIZ ARAMALAR ====================

// Bulutfon API'den cevapsız aramaları getir
async function fetchMissedCalls(apiKey) {
  try {
    const response = await fetch(
      'https://us-central1-uyekayit-5964b.cloudfunctions.net/bulutfonProxy',
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          endpoint: '/cdrs',
          params: {
            is_missing_call: true,
            filter: {
              hangup_cause: 'NO_ANSWER'
            }
          },
          apiKey: apiKey
        })
      }
    );

    if (!response.ok) {
      throw new Error(`Bulutfon API error: ${response.status}`);
    }

    const data = await response.json();
    return data.cdrs || [];
  } catch (error) {
    console.error('❌ Bulutfon API hatası:', error.message);
    return [];
  }
}

// Mesaj gönderme saatleri kontrolü
function checkMessageSendingHours(callTime, messageSendingHours) {
  if (!messageSendingHours?.enabled) {
    return true;
  }

  const callDate = new Date(callTime);
  const dayOfWeek = callDate.getDay();
  const hours = callDate.getHours();
  const minutes = callDate.getMinutes();
  const timeInMinutes = hours * 60 + minutes;

  if (!messageSendingHours.days?.includes(dayOfWeek)) {
    return false;
  }

  const [startHour, startMinute] = (messageSendingHours.start || '09:00').split(':').map(Number);
  const [endHour, endMinute] = (messageSendingHours.end || '18:00').split(':').map(Number);
  
  const startInMinutes = startHour * 60 + startMinute;
  const endInMinutes = endHour * 60 + endMinute;

  return timeInMinutes >= startInMinutes && timeInMinutes <= endInMinutes;
}

// Telefon numarasına uygun WhatsApp cihazını bul
function findMatchingDevice(callee, devices) {
  const calleeLast10 = callee.replace(/\D/g, '').slice(-10);
  
  return devices.find(device => {
    if (!device.phoneNumber) return false;
    const deviceLast10 = device.phoneNumber.replace(/\D/g, '').slice(-10);
    return deviceLast10 === calleeLast10;
  });
}

// Cevapsız aramaları işle ve kuyruğa ekle
async function processMissedCalls() {
  console.log('\n📞 Cevapsız aramalar kontrol ediliyor...');

  try {
    // Kulüpleri al
    const { data: clubs, error: clubsError } = await supabase
      .from('clubs')
      .select('id, name');

    if (clubsError) throw clubsError;

    for (const club of clubs) {
      // Kulüp ayarlarını al
      const { data: settings, error: settingsError } = await supabase
        .from('settings')
        .select('data')
        .eq('clubId', club.id)
        .order('updatedAt', { ascending: false })
        .limit(1)
        .single();

      if (settingsError || !settings?.data) {
        console.log(`⚠️ ${club.name}: Ayarlar bulunamadı`);
        continue;
      }

      const clubSettings = settings.data;

      if (!clubSettings.autoReplySettings?.enabled) {
        console.log(`⏸️ ${club.name}: Otomatik cevap kapalı`);
        continue;
      }

      // WhatsApp cihazlarını al
      const { data: devices } = await supabase
        .from('whatsappDevices')
        .select('id, instanceName, phoneNumber')
        .eq('clubId', club.id);

      if (!devices || devices.length === 0) {
        console.log(`⚠️ ${club.name}: WhatsApp cihazı yok`);
        continue;
      }

      // Cevapsız aramaları al
      const missedCalls = await fetchMissedCalls(clubSettings.bulutfonApiKey);

      if (missedCalls.length === 0) {
        console.log(`✅ ${club.name}: Yeni cevapsız arama yok`);
        continue;
      }

      console.log(`📋 ${club.name}: ${missedCalls.length} cevapsız arama bulundu`);

      // Bugün hangi telefon+şablon kombinasyonlarına mesaj gönderilmiş?
      const today = new Date();
      today.setHours(0, 0, 0, 0);

      const { data: sentToday } = await supabase
        .from('autoReplySent')
        .select('phoneNumber, templateType')
        .eq('clubId', club.id)
        .gte('sentAt', today.toISOString());

      const sentCombinations = new Set(
        (sentToday || []).map(s => `${s.phoneNumber}_${s.templateType}`)
      );

      // Her aramayı işle
      for (const call of missedCalls) {
        const callerNumber = call.caller;
        const callTime = call.datetime;
        const callee = call.callee;

        // Mesaj saati kontrolü
        if (!checkMessageSendingHours(callTime, clubSettings.messageSendingHours)) {
          console.log(`⏰ Mesaj saati dışında: ${callerNumber}`);
          continue;
        }

        // Cihaz eşleştir
        const device = findMatchingDevice(callee, devices);
        if (!device) {
          console.log(`⚠️ Cihaz bulunamadı: ${callee}`);
          continue;
        }

        // Şablon kontrolü
        const template = clubSettings.autoReplySettings.crmTemplates?.[0];
        if (!template?.templateName || !template?.message) {
          console.log(`⚠️ Geçerli şablon yok`);
          continue;
        }

        // Bugün aynı telefon+şablon kombinasyonuna mesaj gönderilmiş mi?
        const combinationKey = `${callerNumber}_${template.templateName}`;
        if (sentCombinations.has(combinationKey)) {
          console.log(`⏭️ Bugün zaten gönderildi: ${callerNumber} (${template.templateName})`);
          continue;
        }

        // Mesajı hazırla
        const message = template.message.replace('{TARIH}', new Date().toLocaleDateString('tr-TR'));

        // Kuyruğa ekle
        const { error: queueError } = await supabase
          .from('message_queue')
          .insert({
            id: crypto.randomUUID(),
            club_id: club.id,
            device_id: device.id,
            to_number: callerNumber,
            message_text: message,
            scheduled_at: new Date().toISOString(),
            status: 'pending'
          });

        if (queueError) {
          console.error(`❌ Kuyruğa eklenemedi (${callerNumber}):`, queueError);
          continue;
        }

        // autoReplySent tablosuna kaydet
        await supabase
          .from('autoReplySent')
          .insert({
            clubId: club.id,
            phoneNumber: callerNumber,
            templateType: template.templateName,
            sentAt: new Date().toISOString()
          });

        console.log(`✅ Mesaj kuyruğa eklendi: ${callerNumber} (${device.instanceName})`);
        sentCombinations.add(combinationKey);
      }
    }
  } catch (error) {
    console.error('❌ Cevapsız arama işleme hatası:', error);
  }
}

// ==================== PART 2: MESAJ KUYRUĞU ====================

// Evolution API'ye mesaj gönder
async function sendWhatsAppMessage(instanceName, phoneNumber, message) {
  try {
    const url = `https://evo-2.edu-ai.online/message/sendText/${instanceName}`;
    
    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'apikey': 'B6D711FCDE4D4FD5936544120E713976'
      },
      body: JSON.stringify({
        number: phoneNumber,
        text: message
      })
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`Evolution API error: ${response.status} - ${errorText}`);
    }

    const result = await response.json();
    console.log(`✅ Mesaj gönderildi: ${phoneNumber} (${instanceName})`);
    return result;
  } catch (error) {
    console.error(`❌ Mesaj gönderilemedi (${phoneNumber}):`, error.message);
    throw error;
  }
}

// Kuyruktaki mesajları işle
async function processMessageQueue() {
  console.log('\n📨 Mesaj kuyruğu işleniyor...');

  try {
    const { data: pendingMessages, error: fetchError } = await supabase
      .from('message_queue')
      .select(`
        *,
        whatsapp_devices!inner(device_name)
      `)
      .eq('status', 'pending')
      .lte('scheduled_at', new Date().toISOString())
      .order('scheduled_at', { ascending: true })
      .limit(50);

    if (fetchError) {
      console.error('❌ Kuyruk okunamadı:', fetchError);
      return;
    }

    if (!pendingMessages || pendingMessages.length === 0) {
      console.log('✅ Kuyrukta bekleyen mesaj yok');
      return;
    }

    console.log(`📬 ${pendingMessages.length} mesaj gönderilecek`);

    for (const msg of pendingMessages) {
      try {
        const instanceName = msg.whatsapp_devices?.device_name;
        
        if (!instanceName) {
          await supabase
            .from('message_queue')
            .update({
              status: 'failed',
              sent_at: new Date().toISOString(),
              error_message: 'WhatsApp device not found'
            })
            .eq('id', msg.id);
          
          continue;
        }

        await sendWhatsAppMessage(instanceName, msg.to_number, msg.message_text);

        await supabase
          .from('message_queue')
          .update({
            status: 'sent',
            sent_at: new Date().toISOString()
          })
          .eq('id', msg.id);

      } catch (error) {
        await supabase
          .from('message_queue')
          .update({
            status: 'failed',
            sent_at: new Date().toISOString(),
            error_message: error.message
          })
          .eq('id', msg.id);
      }
    }

    console.log('✅ Kuyruk işleme tamamlandı');

  } catch (error) {
    console.error('❌ Kuyruk işleme hatası:', error);
  }
}

// ==================== ANA FONKSİYON ====================

async function main() {
  console.log('🚀 Birleşik Otomatik Cevap Sistemi Başlatıldı');
  console.log(`📡 Supabase: ${process.env.SUPABASE_URL}`);
  console.log(`📱 Evolution API: evo-2.edu-ai.online`);
  console.log(`⏰ Çalışma Zamanı: ${new Date().toLocaleString('tr-TR')}`);
  
  // 1. Önce cevapsız aramaları kontrol et ve kuyruğa ekle
  await processMissedCalls();
  
  // 2. Sonra kuyruktaki mesajları gönder
  await processMessageQueue();
  
  console.log('\n✅ Tüm işlemler tamamlandı\n');
}

main();
