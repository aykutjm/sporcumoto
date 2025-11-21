// 🚀 Supabase Edge Function - WhatsApp Mesaj Kuyruğu İşleyicisi
// 7/24 çalışır, web sitesi kapalı olsa bile mesajları gönderir

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

interface WhatsAppMessage {
  id: string
  clubId: string
  phone: string
  message: string
  deviceId: string
  recipientName?: string
  status: string
  scheduledFor: string
}

Deno.serve(async (req) => {
  try {
    console.log('🚀 WhatsApp Queue Processor başlatıldı...')
    
    // Supabase client oluştur (Service Role Key ile - tüm izinler)
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseKey)
    
    // Evolution API bilgileri
    const evolutionUrl = Deno.env.get('EVOLUTION_API_URL')
    const evolutionKey = Deno.env.get('EVOLUTION_API_KEY')
    
    if (!evolutionUrl || !evolutionKey) {
      throw new Error('Evolution API credentials eksik! Environment variables kontrol et.')
    }
    
    console.log('📊 Bekleyen mesajlar kontrol ediliyor...')
    
    // Zamanı gelmiş bekleyen mesajları getir (maksimum 10)
    const { data: messages, error } = await supabase
      .from('messageQueue')
      .select('*')
      .eq('status', 'pending')
      .lte('scheduledFor', new Date().toISOString())
      .order('scheduledFor', { ascending: true })
      .limit(10)
    
    if (error) {
      console.error('❌ Database error:', error)
      throw error
    }
    
    if (!messages || messages.length === 0) {
      console.log('✅ Bekleyen mesaj yok')
      return new Response(
        JSON.stringify({ 
          success: true,
          processed: 0, 
          failed: 0,
          message: 'Bekleyen mesaj yok' 
        }), 
        {
          headers: { 'Content-Type': 'application/json' },
          status: 200
        }
      )
    }
    
    console.log(`📨 ${messages.length} mesaj işlenecek...`)
    
    let processed = 0
    let failed = 0
    const errors: string[] = []
    
    // Her mesajı sırayla işle
    for (const msg of messages as WhatsAppMessage[]) {
      try {
        console.log(`📤 Mesaj gönderiliyor: ${msg.phone} (ID: ${msg.id})`)
        
        // Telefon numarasını formatla
        let phone = msg.phone.replace(/\D/g, '')
        
        // Türkiye formatına çevir
        if (phone.startsWith('0') && phone.length === 11) {
          // 05449367543 → 905449367543
          phone = '90' + phone.substring(1)
        } else if (!phone.startsWith('90')) {
          phone = '90' + phone
        }
        
        const formattedPhone = `${phone}@s.whatsapp.net`
        
        console.log(`  → Formatlanmış telefon: ${formattedPhone}`)
        console.log(`  → Device: ${msg.deviceId}`)
        
        // WhatsApp API'sine mesaj gönder (Evolution API)
        const apiUrl = `${evolutionUrl}/message/sendText/${msg.deviceId}`
        console.log(`  → API URL: ${apiUrl}`)
        
        const response = await fetch(apiUrl, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'apikey': evolutionKey
          },
          body: JSON.stringify({
            number: formattedPhone,
            text: msg.message
          })
        })
        
        const responseData = await response.json().catch(() => ({}))
        console.log(`  → API Response: ${response.status}`, responseData)
        
        if (response.ok) {
          // ✅ Başarılı - durumu güncelle
          const { error: updateError } = await supabase
            .from('messageQueue')
            .update({
              status: 'sent',
              sentAt: new Date().toISOString(),
              updatedAt: new Date().toISOString()
            })
            .eq('id', msg.id)
          
          if (updateError) {
            console.error('  ❌ Status güncelleme hatası:', updateError)
          } else {
            console.log('  ✅ Mesaj başarıyla gönderildi!')
            processed++
          }
          
        } else {
          throw new Error(`API error: ${response.status} - ${JSON.stringify(responseData)}`)
        }
        
        // Rate limiting - mesajlar arası 2 saniye bekle
        if (processed < messages.length) {
          await new Promise(resolve => setTimeout(resolve, 2000))
        }
        
      } catch (error) {
        // ❌ Hata - durumu güncelle
        const errorMessage = error instanceof Error ? error.message : 'Bilinmeyen hata'
        console.error(`  ❌ Mesaj gönderilirken hata:`, errorMessage)
        errors.push(`${msg.phone}: ${errorMessage}`)
        
        await supabase
          .from('messageQueue')
          .update({
            status: 'failed',
            error: errorMessage,
            failedAt: new Date().toISOString(),
            updatedAt: new Date().toISOString()
          })
          .eq('id', msg.id)
        
        failed++
      }
    }
    
    const result = {
      success: true,
      processed,
      failed,
      total: messages.length,
      timestamp: new Date().toISOString(),
      errors: errors.length > 0 ? errors : undefined
    }
    
    console.log('🎉 İşlem tamamlandı:', result)
    
    return new Response(
      JSON.stringify(result),
      { 
        headers: { 'Content-Type': 'application/json' },
        status: 200
      }
    )
    
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : 'Bilinmeyen hata'
    console.error('❌ Fatal error:', errorMessage)
    
    return new Response(
      JSON.stringify({ 
        success: false,
        error: errorMessage,
        timestamp: new Date().toISOString()
      }),
      { 
        status: 500, 
        headers: { 'Content-Type': 'application/json' } 
      }
    )
  }
})
