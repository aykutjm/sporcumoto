// Gelişmiş Otomatik Mesaj Sistemi - 5 Senaryo
// 1. Cevapsız Aramalar (mesai saatleri içinde)
// 2. Gecikmiş Ödemeler
// 3. Devamsızlık Uyarıları
// 4. Yaklaşan Ödeme Hatırlatmaları
// 5. Deneme Dersi Hatırlatmaları

import { createClient } from '@supabase/supabase-js';
import 'dotenv/config';
import crypto from 'crypto';

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_KEY
);

// ==================== YARDIMCI FONKSİYONLAR ====================

// Şablondaki gün ve saat kontrolü
function checkTemplateSchedule(template) {
  const now = new Date();
  const dayOfWeek = now.getDay(); // 0-6 (Pazar-Cumartesi)
  const currentHour = now.getHours();
  const currentMinute = now.getMinutes();
  
  // Gün kontrolü (şablonun send_days ayarı)
  if (!template.send_days?.includes(dayOfWeek)) {
    return false;
  }
  
  // Saat kontrolü (şablonun send_time ayarı)
  if (template.send_time) {
    const [targetHour, targetMinute] = template.send_time.split(':').map(Number);
    
    // Sadece belirlenen saatte çalışsın (±5 dakika tolerans)
    if (currentHour !== targetHour) {
      return false;
    }
    
    const timeDiff = Math.abs(currentMinute - targetMinute);
    if (timeDiff > 5) {
      return false;
    }
  }
  
  return true;
}

// Mesai saatleri kontrolü (sadece cevapsız aramalar için)
function checkBusinessHours(callTime, messageSendingHours) {
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
    return result;
  } catch (error) {
    console.error(`❌ Mesaj gönderilemedi (${phoneNumber}):`, error.message);
    throw error;
  }
}

// ==================== SENARYO 1: CEVAPSIZ ARAMALAR ====================

async function processMissedCalls(club, clubSettings, devices) {
  try {
    // Cevapsız arama şablonunu al
    const { data: template } = await supabase
      .from('message_templates')
      .select('*')
      .eq('club_id', club.id)
      .eq('category', 'missed_call')
      .eq('is_active', true)
      .maybeSingle();

    if (!template) {
      console.log(`⏸️ ${club.name}: Cevapsız arama şablonu yok veya pasif`);
      return;
    }

    // Şablonun gün ve saat ayarlarını kontrol et
    if (!checkTemplateSchedule(template)) {
      console.log(`⏰ ${club.name}: Cevapsız aramalar için uygun zaman değil`);
      return;
    }

    // Cevapsız aramaları al
    const missedCalls = await fetchMissedCalls(clubSettings.bulutfonApiKey);

    if (missedCalls.length === 0) {
      console.log(`✅ ${club.name}: Yeni cevapsız arama yok`);
      return;
    }

    console.log(`📞 ${club.name}: ${missedCalls.length} cevapsız arama bulundu`);

    // Bugün gönderilenleri kontrol et
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

      // MESAİ SAATLERİ KONTROLÜ (sadece cevapsız aramalar için)
      if (!checkBusinessHours(callTime, clubSettings.messageSendingHours)) {
        console.log(`⏰ Mesai saati dışında arama: ${callerNumber}`);
        continue;
      }

      // Cihaz eşleştir
      const device = findMatchingDevice(callee, devices);
      if (!device) {
        console.log(`⚠️ Cihaz bulunamadı: ${callee}`);
        continue;
      }

      // Bugün aynı kombinasyona gönderilmiş mi?
      const combinationKey = `${callerNumber}_${template.template_name}`;
      if (sentCombinations.has(combinationKey)) {
        console.log(`⏭️ Bugün zaten gönderildi: ${callerNumber}`);
        continue;
      }

      // Mesajı hazırla
      const message = template.message
        .replace('{TARIH}', new Date().toLocaleDateString('tr-TR'));

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
          templateType: template.template_name,
          sentAt: new Date().toISOString()
        });

      console.log(`✅ Cevapsız arama mesajı kuyruğa eklendi: ${callerNumber}`);
      sentCombinations.add(combinationKey);
    }
  } catch (error) {
    console.error(`❌ ${club.name}: Cevapsız arama işleme hatası:`, error);
  }
}

// ==================== SENARYO 2: GECİKMİŞ ÖDEMELER ====================

async function processOverduePayments(club, devices) {
  try {
    // Gecikmiş ödeme şablonunu al
    const { data: template } = await supabase
      .from('message_templates')
      .select('*')
      .eq('club_id', club.id)
      .eq('category', 'overdue_payment')
      .eq('is_active', true)
      .maybeSingle();

    if (!template) {
      console.log(`⏸️ ${club.name}: Gecikmiş ödeme şablonu yok veya pasif`);
      return;
    }

    // Şablonun gün ve saat ayarlarını kontrol et
    if (!checkTemplateSchedule(template)) {
      console.log(`⏰ ${club.name}: Gecikmiş ödemeler için uygun zaman değil`);
      return;
    }

    // Gecikmiş ödemeleri bul
    const today = new Date();
    const { data: overduePayments } = await supabase
      .from('accounting')
      .select(`
        id,
        customerId,
        customers!inner(name, phone)
      `)
      .eq('branchId', club.id)
      .eq('type', 'income')
      .eq('status', 'pending')
      .lt('dueDate', today.toISOString());

    if (!overduePayments || overduePayments.length === 0) {
      console.log(`✅ ${club.name}: Gecikmiş ödeme yok`);
      return;
    }

    console.log(`💰 ${club.name}: ${overduePayments.length} gecikmiş ödeme bulundu`);

    // Bugün gönderilenleri kontrol et
    const todayStart = new Date();
    todayStart.setHours(0, 0, 0, 0);

    const { data: sentToday } = await supabase
      .from('autoReplySent')
      .select('phoneNumber, templateType')
      .eq('clubId', club.id)
      .gte('sentAt', todayStart.toISOString());

    const sentCombinations = new Set(
      (sentToday || []).map(s => `${s.phoneNumber}_${s.templateType}`)
    );

    // Her ödemeyi işle
    for (const payment of overduePayments) {
      const phoneNumber = payment.customers?.phone;
      if (!phoneNumber) continue;

      const combinationKey = `${phoneNumber}_${template.template_name}`;
      if (sentCombinations.has(combinationKey)) {
        console.log(`⏭️ Bugün zaten gönderildi: ${phoneNumber}`);
        continue;
      }

      // İlk aktif cihazı al
      const device = devices[0];
      if (!device) {
        console.log(`⚠️ WhatsApp cihazı yok`);
        break;
      }

      // Mesajı hazırla
      const message = template.message
        .replace('{ISIM}', payment.customers.name)
        .replace('{TARIH}', new Date().toLocaleDateString('tr-TR'));

      // Kuyruğa ekle
      await supabase
        .from('message_queue')
        .insert({
          id: crypto.randomUUID(),
          club_id: club.id,
          device_id: device.id,
          to_number: phoneNumber,
          message_text: message,
          scheduled_at: new Date().toISOString(),
          status: 'pending'
        });

      await supabase
        .from('autoReplySent')
        .insert({
          clubId: club.id,
          phoneNumber: phoneNumber,
          templateType: template.template_name,
          sentAt: new Date().toISOString()
        });

      console.log(`✅ Gecikmiş ödeme mesajı kuyruğa eklendi: ${phoneNumber}`);
      sentCombinations.add(combinationKey);
    }
  } catch (error) {
    console.error(`❌ ${club.name}: Gecikmiş ödeme işleme hatası:`, error);
  }
}

// ==================== SENARYO 3: DEVAMSIZLIK UYARILARI ====================

async function processAbsences(club, devices) {
  try {
    // Devamsızlık şablonunu al
    const { data: template } = await supabase
      .from('message_templates')
      .select('*')
      .eq('club_id', club.id)
      .eq('category', 'absence')
      .eq('is_active', true)
      .maybeSingle();

    if (!template) {
      console.log(`⏸️ ${club.name}: Devamsızlık şablonu yok veya pasif`);
      return;
    }

    // Şablonun gün ve saat ayarlarını kontrol et
    if (!checkTemplateSchedule(template)) {
      console.log(`⏰ ${club.name}: Devamsızlık kontrolü için uygun zaman değil`);
      return;
    }

    // Son 7 gündeki yoklamaları kontrol et
    const weekAgo = new Date();
    weekAgo.setDate(weekAgo.getDate() - 7);

    const { data: absences } = await supabase
      .from('attendance')
      .select(`
        id,
        customerId,
        customers!inner(name, phone)
      `)
      .eq('branchId', club.id)
      .eq('status', 'absent')
      .gte('date', weekAgo.toISOString());

    if (!absences || absences.length === 0) {
      console.log(`✅ ${club.name}: Devamsızlık yok`);
      return;
    }

    // Müşteri bazında grupla (aynı müşteriye birden fazla mesaj gitmesin)
    const customerAbsences = new Map();
    absences.forEach(absence => {
      const count = customerAbsences.get(absence.customerId) || 0;
      customerAbsences.set(absence.customerId, count + 1);
    });

    console.log(`📋 ${club.name}: ${customerAbsences.size} müşteri devamsızlık yaptı`);

    // Bugün gönderilenleri kontrol et
    const todayStart = new Date();
    todayStart.setHours(0, 0, 0, 0);

    const { data: sentToday } = await supabase
      .from('autoReplySent')
      .select('phoneNumber, templateType')
      .eq('clubId', club.id)
      .gte('sentAt', todayStart.toISOString());

    const sentCombinations = new Set(
      (sentToday || []).map(s => `${s.phoneNumber}_${s.templateType}`)
    );

    // İlk aktif cihazı al
    const device = devices[0];
    if (!device) {
      console.log(`⚠️ WhatsApp cihazı yok`);
      return;
    }

    // Her müşteriye mesaj gönder
    for (const absence of absences) {
      const phoneNumber = absence.customers?.phone;
      if (!phoneNumber) continue;

      const combinationKey = `${phoneNumber}_${template.template_name}`;
      if (sentCombinations.has(combinationKey)) {
        console.log(`⏭️ Bugün zaten gönderildi: ${phoneNumber}`);
        continue;
      }

      // Mesajı hazırla
      const message = template.message
        .replace('{ISIM}', absence.customers.name)
        .replace('{TARIH}', new Date().toLocaleDateString('tr-TR'));

      // Kuyruğa ekle
      await supabase
        .from('message_queue')
        .insert({
          id: crypto.randomUUID(),
          club_id: club.id,
          device_id: device.id,
          to_number: phoneNumber,
          message_text: message,
          scheduled_at: new Date().toISOString(),
          status: 'pending'
        });

      await supabase
        .from('autoReplySent')
        .insert({
          clubId: club.id,
          phoneNumber: phoneNumber,
          templateType: template.template_name,
          sentAt: new Date().toISOString()
        });

      console.log(`✅ Devamsızlık mesajı kuyruğa eklendi: ${phoneNumber}`);
      sentCombinations.add(combinationKey);
    }
  } catch (error) {
    console.error(`❌ ${club.name}: Devamsızlık işleme hatası:`, error);
  }
}

// ==================== SENARYO 4: YAKLAŞAN ÖDEMELER ====================

async function processUpcomingPayments(club, devices) {
  try {
    // Yaklaşan ödeme şablonunu al
    const { data: template } = await supabase
      .from('message_templates')
      .select('*')
      .eq('club_id', club.id)
      .eq('category', 'upcoming_payment')
      .eq('is_active', true)
      .maybeSingle();

    if (!template) {
      console.log(`⏸️ ${club.name}: Yaklaşan ödeme şablonu yok veya pasif`);
      return;
    }

    // Şablonun gün ve saat ayarlarını kontrol et
    if (!checkTemplateSchedule(template)) {
      console.log(`⏰ ${club.name}: Yaklaşan ödemeler için uygun zaman değil`);
      return;
    }

    // Önümüzdeki 3 gün içinde ödemesi olan müşteriler
    const today = new Date();
    const threeDaysLater = new Date();
    threeDaysLater.setDate(today.getDate() + 3);

    const { data: upcomingPayments } = await supabase
      .from('accounting')
      .select(`
        id,
        customerId,
        dueDate,
        customers!inner(name, phone)
      `)
      .eq('branchId', club.id)
      .eq('type', 'income')
      .eq('status', 'pending')
      .gte('dueDate', today.toISOString())
      .lte('dueDate', threeDaysLater.toISOString());

    if (!upcomingPayments || upcomingPayments.length === 0) {
      console.log(`✅ ${club.name}: Yaklaşan ödeme yok`);
      return;
    }

    console.log(`💳 ${club.name}: ${upcomingPayments.length} yaklaşan ödeme bulundu`);

    // Bugün gönderilenleri kontrol et
    const todayStart = new Date();
    todayStart.setHours(0, 0, 0, 0);

    const { data: sentToday } = await supabase
      .from('autoReplySent')
      .select('phoneNumber, templateType')
      .eq('clubId', club.id)
      .gte('sentAt', todayStart.toISOString());

    const sentCombinations = new Set(
      (sentToday || []).map(s => `${s.phoneNumber}_${s.templateType}`)
    );

    // İlk aktif cihazı al
    const device = devices[0];
    if (!device) {
      console.log(`⚠️ WhatsApp cihazı yok`);
      return;
    }

    // Her ödemeyi işle
    for (const payment of upcomingPayments) {
      const phoneNumber = payment.customers?.phone;
      if (!phoneNumber) continue;

      const combinationKey = `${phoneNumber}_${template.template_name}`;
      if (sentCombinations.has(combinationKey)) {
        console.log(`⏭️ Bugün zaten gönderildi: ${phoneNumber}`);
        continue;
      }

      // Mesajı hazırla
      const dueDate = new Date(payment.dueDate).toLocaleDateString('tr-TR');
      const message = template.message
        .replace('{ISIM}', payment.customers.name)
        .replace('{TARIH}', dueDate);

      // Kuyruğa ekle
      await supabase
        .from('message_queue')
        .insert({
          id: crypto.randomUUID(),
          club_id: club.id,
          device_id: device.id,
          to_number: phoneNumber,
          message_text: message,
          scheduled_at: new Date().toISOString(),
          status: 'pending'
        });

      await supabase
        .from('autoReplySent')
        .insert({
          clubId: club.id,
          phoneNumber: phoneNumber,
          templateType: template.template_name,
          sentAt: new Date().toISOString()
        });

      console.log(`✅ Yaklaşan ödeme mesajı kuyruğa eklendi: ${phoneNumber}`);
      sentCombinations.add(combinationKey);
    }
  } catch (error) {
    console.error(`❌ ${club.name}: Yaklaşan ödeme işleme hatası:`, error);
  }
}

// ==================== SENARYO 5: DENEME DERSİ HATIRLATMALARI ====================

async function processTrialLessons(club, devices) {
  try {
    // Deneme dersi şablonunu al
    const { data: template } = await supabase
      .from('message_templates')
      .select('*')
      .eq('club_id', club.id)
      .eq('category', 'trial_lesson')
      .eq('is_active', true)
      .maybeSingle();

    if (!template) {
      console.log(`⏸️ ${club.name}: Deneme dersi şablonu yok veya pasif`);
      return;
    }

    // Şablonun gün ve saat ayarlarını kontrol et
    if (!checkTemplateSchedule(template)) {
      console.log(`⏰ ${club.name}: Deneme dersi kontrolü için uygun zaman değil`);
      return;
    }

    // Yarın deneme dersi olan müşteriler
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    tomorrow.setHours(0, 0, 0, 0);
    
    const dayAfterTomorrow = new Date(tomorrow);
    dayAfterTomorrow.setDate(tomorrow.getDate() + 1);

    const { data: trialLessons } = await supabase
      .from('customers')
      .select('id, name, phone, trialLessonDate')
      .eq('branchId', club.id)
      .eq('status', 'trial')
      .gte('trialLessonDate', tomorrow.toISOString())
      .lt('trialLessonDate', dayAfterTomorrow.toISOString());

    if (!trialLessons || trialLessons.length === 0) {
      console.log(`✅ ${club.name}: Yarın deneme dersi yok`);
      return;
    }

    console.log(`🎓 ${club.name}: ${trialLessons.length} deneme dersi hatırlatması bulundu`);

    // Bugün gönderilenleri kontrol et
    const todayStart = new Date();
    todayStart.setHours(0, 0, 0, 0);

    const { data: sentToday } = await supabase
      .from('autoReplySent')
      .select('phoneNumber, templateType')
      .eq('clubId', club.id)
      .gte('sentAt', todayStart.toISOString());

    const sentCombinations = new Set(
      (sentToday || []).map(s => `${s.phoneNumber}_${s.templateType}`)
    );

    // İlk aktif cihazı al
    const device = devices[0];
    if (!device) {
      console.log(`⚠️ WhatsApp cihazı yok`);
      return;
    }

    // Her deneme dersini işle
    for (const customer of trialLessons) {
      const phoneNumber = customer.phone;
      if (!phoneNumber) continue;

      const combinationKey = `${phoneNumber}_${template.template_name}`;
      if (sentCombinations.has(combinationKey)) {
        console.log(`⏭️ Bugün zaten gönderildi: ${phoneNumber}`);
        continue;
      }

      // Mesajı hazırla
      const lessonDate = new Date(customer.trialLessonDate).toLocaleDateString('tr-TR');
      const message = template.message
        .replace('{ISIM}', customer.name)
        .replace('{TARIH}', lessonDate);

      // Kuyruğa ekle
      await supabase
        .from('message_queue')
        .insert({
          id: crypto.randomUUID(),
          club_id: club.id,
          device_id: device.id,
          to_number: phoneNumber,
          message_text: message,
          scheduled_at: new Date().toISOString(),
          status: 'pending'
        });

      await supabase
        .from('autoReplySent')
        .insert({
          clubId: club.id,
          phoneNumber: phoneNumber,
          templateType: template.template_name,
          sentAt: new Date().toISOString()
        });

      console.log(`✅ Deneme dersi mesajı kuyruğa eklendi: ${phoneNumber}`);
      sentCombinations.add(combinationKey);
    }
  } catch (error) {
    console.error(`❌ ${club.name}: Deneme dersi işleme hatası:`, error);
  }
}

// ==================== MESAJ KUYRUĞU İŞLEME ====================

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

        console.log(`✅ Mesaj gönderildi: ${msg.to_number}`);

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
  console.log('🚀 Gelişmiş Otomatik Mesaj Sistemi Başlatıldı');
  console.log(`📡 Supabase: ${process.env.SUPABASE_URL}`);
  console.log(`📱 Evolution API: evo-2.edu-ai.online`);
  console.log(`⏰ Çalışma Zamanı: ${new Date().toLocaleString('tr-TR', { timeZone: 'Europe/Istanbul' })}`);
  console.log('');
  
  try {
    // Kulüpleri al
    const { data: clubs, error: clubsError } = await supabase
      .from('clubs')
      .select('id, name');

    if (clubsError) throw clubsError;

    console.log(`🏢 ${clubs.length} kulüp kontrol ediliyor...\n`);

    for (const club of clubs) {
      console.log(`\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`);
      console.log(`🏢 ${club.name}`);
      console.log(`━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`);

      // Kulüp ayarlarını al
      const { data: settings, error: settingsError } = await supabase
        .from('settings')
        .select('data')
        .eq('clubId', club.id)
        .order('updatedAt', { ascending: false })
        .limit(1)
        .maybeSingle();

      if (settingsError || !settings?.data) {
        console.log(`⚠️ ${club.name}: Ayarlar bulunamadı`);
        continue;
      }

      const clubSettings = settings.data;

      // WhatsApp cihazlarını al
      const { data: devices } = await supabase
        .from('whatsappDevices')
        .select('id, instanceName, phoneNumber')
        .eq('clubId', club.id);

      if (!devices || devices.length === 0) {
        console.log(`⚠️ ${club.name}: WhatsApp cihazı yok`);
        continue;
      }

      // 5 senaryoyu çalıştır
      await processMissedCalls(club, clubSettings, devices);
      await processOverduePayments(club, devices);
      await processAbsences(club, devices);
      await processUpcomingPayments(club, devices);
      await processTrialLessons(club, devices);
    }

    console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('📨 MESAJ KUYRUĞU İŞLENİYOR');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    // Kuyruktaki mesajları gönder
    await processMessageQueue();

    console.log('\n✅ TÜM İŞLEMLER TAMAMLANDI\n');

  } catch (error) {
    console.error('❌ Ana fonksiyon hatası:', error);
  }
}

main();
