// Auto-Reply to Missed Calls - Supabase Edge Function
// Her 2 dakikada bir çalışır (Supabase Cron ile)

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3';

const BULUTFON_API_URL = 'https://api.bulutfon.com';

interface MissedCall {
  uuid: string;
  caller: string;
  callee: string;
  call_time: string;
  direction: string;
}

interface WhatsAppDevice {
  instanceName: string;
  phoneNumber: string;
  status: string;
}

interface ClubSettings {
  workingHoursEnabled?: boolean;
  workingHoursStart?: string;
  workingHoursEnd?: string;
  workingDays?: number[];
  bulutfonApiKey?: string;
}

serve(async (req) => {
  try {
    console.log('🚀 Auto-reply Edge Function başlatıldı');

    // Supabase client oluştur
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Tüm aktif kulüpleri al
    const { data: clubs, error: clubsError } = await supabase
      .from('clubs')
      .select('id, settings')
      .eq('active', true);

    if (clubsError) throw clubsError;

    console.log(`📊 ${clubs?.length || 0} aktif kulüp bulundu`);

    let totalMessagesSent = 0;

    // Her kulüp için kontrol yap
    for (const club of clubs || []) {
      const clubId = club.id;
      const settings: ClubSettings = club.settings || {};

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

      // Bugün gönderilen mesajları al (duplicate kontrolü)
      const today = new Date().toISOString().split('T')[0];
      const { data: sentToday, error: sentError } = await supabase
        .from('autoReplySent')
        .select('phone')
        .eq('clubId', clubId)
        .gte('sentDate', `${today}T00:00:00.000Z`)
        .lt('sentDate', `${today}T23:59:59.999Z`);

      const sentPhones = new Set((sentToday || []).map(s => s.phone));

      // CRM mesaj şablonunu al
      const { data: templates, error: templatesError } = await supabase
        .from('messageTemplates')
        .select('templates')
        .eq('clubId', clubId)
        .single();

      const messageTemplate = templates?.templates?.['incoming-missed-call-template']?.message || 
        'Merhaba,\n\nBizi {TARIH} tarihinde aramaya çalıştınız ancak o anda yoğunluktan dolayı telefonunuzu açamadık.\n\nSize nasıl yardımcı olabiliriz?\n\nLütfen bizi tekrar arayabilir veya mesajınızı buradan iletebilirsiniz.\n\nTeşekkürler';

      // Her cevapsız çağrı için işle
      for (const call of missedCalls) {
        const caller = call.caller.replace(/\D/g, '');
        const callee = call.callee.replace(/\D/g, '');

        // Duplicate kontrolü
        if (sentPhones.has(caller)) {
          console.log(`  ⏭️ ${caller} - Bugün zaten mesaj gönderildi`);
          continue;
        }

        // Çalışma saati kontrolü
        if (settings.workingHoursEnabled) {
          const isWorkingHours = checkWorkingHours(call.call_time, settings);
          if (!isWorkingHours) {
            console.log(`  ⏰ ${caller} - Çalışma saati dışında aranmış, atlanıyor`);
            continue;
          }
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
            clubId,
            phone: formattedCaller,
            message: finalMessage,
            deviceId: device.instanceName,
            scheduledFor: new Date().toISOString(),
            status: 'pending',
            createdAt: new Date().toISOString(),
            createdBy: 'Edge Function (Otomatik)',
            type: 'auto_reply_missed_call'
          });

        // Gönderim kaydı oluştur
        await supabase
          .from('autoReplySent')
          .insert({
            clubId,
            phone: caller,
            formattedPhone: formattedCaller,
            sentDate: new Date().toISOString(),
            callTime: call.call_time,
            deviceUsed: device.instanceName
          });

        console.log(`  ✅ Mesaj kuyruğa eklendi: ${formattedCaller} (${device.instanceName})`);
        totalMessagesSent++;
      }
    }

    return new Response(
      JSON.stringify({ 
        success: true, 
        totalMessagesSent,
        timestamp: new Date().toISOString() 
      }),
      { headers: { 'Content-Type': 'application/json' } }
    );

  } catch (error) {
    console.error('❌ Error:', error);
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    );
  }
});

// Bulutfon'dan cevapsız çağrıları al
async function fetchMissedCalls(apiKey: string): Promise<MissedCall[]> {
  try {
    // Son 10 dakikanın çağrılarını al
    const today = new Date();
    const dateStr = today.toISOString().split('T')[0]; // YYYY-MM-DD
    
    const response = await fetch(`${BULUTFON_API_URL}/dids/${dateStr}`, {
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json'
      }
    });

    if (!response.ok) {
      console.error('Bulutfon API error:', response.status);
      return [];
    }

    const data = await response.json();
    
    // Cevapsız çağrıları filtrele (son 10 dakika, gelen aramalar, cevapsız)
    const tenMinutesAgo = new Date(Date.now() - 10 * 60 * 1000);
    
    return (data.dids || [])
      .flatMap((did: any) => did.calls || [])
      .filter((call: MissedCall) => {
        const callDate = new Date(call.call_time);
        return call.direction === 'IN' && 
               callDate > tenMinutesAgo &&
               !call.uuid.includes('answered'); // Cevapsız olanlar
      });
  } catch (error) {
    console.error('Bulutfon fetch error:', error);
    return [];
  }
}

// Çalışma saati kontrolü
function checkWorkingHours(callTime: string, settings: ClubSettings): boolean {
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
function findMatchingDevice(callee: string, devices: WhatsAppDevice[]): WhatsAppDevice | null {
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
