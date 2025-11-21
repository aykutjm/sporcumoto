// 📨 Evolution API WhatsApp Webhook Handler
// Bu Edge Function Evolution API'den gelen webhook'ları alıp Supabase'e kaydeder

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const payload = await req.json()
    console.log('📨 Webhook alındı:', payload)

    // Evolution API webhook formatı:
    // { event: 'messages.upsert', instance: 'atakumtenis', data: {...} }
    
    const { event, instance, data } = payload

    // Club ID'yi instance name'den al (veya mapping kullan)
    const clubId = instance // Varsayılan: instance name = club_id
    
    if (event === 'messages.upsert' && data?.key && data?.message) {
      // 📨 MESAJ KAYDET
      const remoteJid = data.key.remoteJid
      const pushName = data.pushName || data.verifiedBizName || 'Bilinmeyen'
      const messageTimestamp = data.messageTimestamp ? new Date(data.messageTimestamp * 1000) : new Date()
      
      // Kendi mesajımızsa kaydetme
      if (data.key.fromMe) {
        console.log('⏭️ Kendi mesajımız, kaydedilmiyor')
        return new Response(JSON.stringify({ success: true, skipped: 'fromMe' }), {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        })
      }

      const messageData = {
        club_id: clubId,
        remote_jid: remoteJid,
        push_name: pushName,
        instance_name: instance,
        message_timestamp: messageTimestamp.toISOString(),
        message_timestamp_unix: data.messageTimestamp || Math.floor(Date.now() / 1000),
        message_content: data.message,
        message_key: data.key,
        created_at: new Date().toISOString()
      }

      const { data: insertedMessage, error: messageError } = await supabaseClient
        .from('whatsapp_incoming_messages')
        .insert(messageData)
        .select()

      if (messageError) {
        console.error('❌ Mesaj kaydetme hatası:', messageError)
        throw messageError
      }

      console.log('✅ Mesaj kaydedildi:', insertedMessage)

      return new Response(JSON.stringify({ success: true, message: insertedMessage }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    if (event === 'call' && data) {
      // 📞 ÇAĞRI KAYDET
      const callData = {
        club_id: clubId,
        caller_phone: data.from || data.remoteJid?.replace('@s.whatsapp.net', ''),
        caller_name: data.pushName || data.verifiedBizName || 'Bilinmeyen',
        called_number: data.to || instance,
        instance_name: instance,
        call_timestamp: data.date ? new Date(data.date) : new Date(),
        call_status: data.status || 'unknown',
        is_video: data.isVideo || false,
        call_id: data.id || Date.now().toString(),
        is_missing_call: ['ringing', 'missed'].includes(data.status || ''),
        created_at: new Date().toISOString()
      }

      const { data: insertedCall, error: callError } = await supabaseClient
        .from('whatsapp_incoming_calls')
        .insert(callData)
        .select()

      if (callError) {
        console.error('❌ Çağrı kaydetme hatası:', callError)
        throw callError
      }

      console.log('✅ Çağrı kaydedildi:', insertedCall)

      return new Response(JSON.stringify({ success: true, call: insertedCall }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // Diğer event'ler için sadece log
    console.log('ℹ️ Event işlenmedi:', event)
    return new Response(JSON.stringify({ success: true, skipped: event }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })

  } catch (error) {
    console.error('❌ Webhook hatası:', error)
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})
