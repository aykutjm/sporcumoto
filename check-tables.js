import { createClient } from '@supabase/supabase-js';
import 'dotenv/config';

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_KEY
);

async function checkTables() {
  // whatsapp_devices yapısı
  const { data: devices } = await supabase
    .from('whatsapp_devices')
    .select('*')
    .limit(1);
  
  console.log('whatsapp_devices columns:', Object.keys(devices?.[0] || {}));
  
  // message_queue yapısı
  const { data: messages } = await supabase
    .from('message_queue')
    .select('*')
    .limit(1);
  
  console.log('message_queue columns:', Object.keys(messages?.[0] || {}));
}

checkTables();
