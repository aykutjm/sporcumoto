// WhatsApp Mesaj Kuyruğu İşleyici
// Bu script message_queue tablosundaki mesajları Evolution API'ye gönderir

import { createClient } from '@supabase/supabase-js';
import 'dotenv/config';

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_KEY
);

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
  console.log('\n🔄 Mesaj kuyruğu kontrol ediliyor...', new Date().toISOString());

  try {
    // Gönderilmemiş mesajları al (status = 'pending' ve scheduled_at geçmiş)
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
      console.error('❌ Kuyruktaki mesajlar alınamadı:', fetchError);
      return;
    }

    if (!pendingMessages || pendingMessages.length === 0) {
      console.log('✅ Kuyrukta bekleyen mesaj yok');
      return;
    }

    console.log(`📨 ${pendingMessages.length} mesaj işlenecek`);

    for (const msg of pendingMessages) {
      try {
        const instanceName = msg.whatsapp_devices?.device_name;
        
        if (!instanceName) {
          console.error(`❌ Mesaj ${msg.id}: WhatsApp cihazı bulunamadı`);
          
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

        const { error: updateError } = await supabase
          .from('message_queue')
          .update({
            status: 'sent',
            sent_at: new Date().toISOString()
          })
          .eq('id', msg.id);

        if (updateError) {
          console.error(`❌ Mesaj durumu güncellenemedi (${msg.id}):`, updateError);
        }

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

    console.log(`✅ Kuyruk işleme tamamlandı`);

  } catch (error) {
    console.error('❌ Genel hata:', error);
  }
}

// Ana fonksiyon
async function main() {
  console.log('🚀 WhatsApp Mesaj Kuyruğu İşleyici Başlatıldı');
  console.log(`📡 Supabase: ${process.env.SUPABASE_URL}`);
  console.log(`📱 Evolution API: evo-2.edu-ai.online`);
  
  await processMessageQueue();
  
  console.log('\n✅ İşlem tamamlandı\n');
}

main();
