// 🔥 WHATSAPP CİHAZ EKLEME - GELİŞMİŞ HATA AYIKLAMA
// Bu kodu tarayıcı Console'una yapıştırın ve çalıştırın

async function debugWhatsAppDeviceAdd() {
    console.log('🔍 WhatsApp Cihaz Ekleme Debug Başladı...');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
    // Test verileri
    const testInstanceName = 'TEST_' + Date.now();
    const testPhoneNumber = '905515046799';
    const evolutionUrl = 'https://evo-2.edu-ai.online';
    const apiKey = 'iHAF8gWNA1axdRDY9e98UKpork00dBO2';
    
    console.log('📋 Test Parametreleri:');
    console.log('  Instance: ' + testInstanceName);
    console.log('  Phone: ' + testPhoneNumber);
    console.log('  Evolution URL: ' + evolutionUrl);
    console.log('  API Key: ' + apiKey.substring(0, 10) + '...');
    console.log('');
    
    // ═══════════════════════════════════════════════════════════════
    // TEST 1: Evolution API Bağlantısı
    // ═══════════════════════════════════════════════════════════════
    console.log('🧪 TEST 1: Evolution API Bağlantı Kontrolü');
    try {
        const response = await fetch(`${evolutionUrl}/instance/fetchInstances?instanceName=${testInstanceName}`, {
            method: 'GET',
            headers: {
                'apikey': apiKey
            }
        });
        
        console.log('  Status:', response.status, response.statusText);
        
        if (response.status === 403) {
            console.error('  ❌ Evolution API 403 Hatası!');
            console.error('  → API Key yanlış veya süresi dolmuş');
            console.error('  → Çözüm: Evolution API Key\'i kontrol edin');
            return;
        } else if (response.status === 404) {
            console.log('  ✅ API erişilebilir (404 normal - instance yok)');
        } else if (response.ok) {
            console.log('  ✅ API erişilebilir ve çalışıyor');
        } else {
            console.warn('  ⚠️ Beklenmeyen status:', response.status);
        }
    } catch (error) {
        console.error('  ❌ Evolution API\'ye erişilemiyor:', error.message);
        console.error('  → Network hatası veya CORS sorunu');
        return;
    }
    console.log('');
    
    // ═══════════════════════════════════════════════════════════════
    // TEST 2: Supabase Bağlantısı
    // ═══════════════════════════════════════════════════════════════
    console.log('🧪 TEST 2: Supabase Bağlantı Kontrolü');
    try {
        if (!supabaseClient) {
            console.error('  ❌ supabaseClient tanımlı değil!');
            console.error('  → Sayfa yeniden yüklenmeli');
            return;
        }
        
        const { data: testData, error: testError } = await supabaseClient
            .from('whatsappDevices')
            .select('count')
            .limit(1);
        
        if (testError) {
            console.error('  ❌ Supabase Hatası:', testError.message);
            console.error('  → RLS veya yetki problemi olabilir');
            return;
        } else {
            console.log('  ✅ Supabase bağlantısı OK');
        }
    } catch (error) {
        console.error('  ❌ Supabase hata:', error.message);
        return;
    }
    console.log('');
    
    // ═══════════════════════════════════════════════════════════════
    // TEST 3: Supabase INSERT Testi
    // ═══════════════════════════════════════════════════════════════
    console.log('🧪 TEST 3: Supabase INSERT Yetkisi Kontrolü');
    try {
        const testDevice = {
            id: 'TEST_DEVICE_' + Date.now(),
            clubId: currentClubId,
            instanceName: testInstanceName,
            phoneNumber: testPhoneNumber,
            evolutionUrl: evolutionUrl,
            apiKey: apiKey,
            isConnected: false,
            status: 'pending',
            createdBy: currentUser?.email || 'test@test.com',
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
            lastUpdated: new Date().toISOString()
        };
        
        const { data: insertData, error: insertError } = await supabaseClient
            .from('whatsappDevices')
            .insert(testDevice)
            .select()
            .single();
        
        if (insertError) {
            console.error('  ❌ INSERT Hatası:', insertError);
            console.error('  → Kod:', insertError.code);
            console.error('  → Mesaj:', insertError.message);
            console.error('  → Detay:', insertError.details);
            
            if (insertError.code === '42501') {
                console.error('');
                console.error('  🔑 YETKİ SORUNU TESPİT EDİLDİ!');
                console.error('  → SUPABASE-FULL-GRANT.sql dosyasını çalıştırın');
            }
            return;
        } else {
            console.log('  ✅ INSERT başarılı! Test cihaz eklendi.');
            console.log('  → ID:', insertData.id);
            
            // Test cihazı sil
            const { error: deleteError } = await supabaseClient
                .from('whatsappDevices')
                .delete()
                .eq('id', testDevice.id);
            
            if (deleteError) {
                console.warn('  ⚠️ Test cihaz silinemedi:', deleteError.message);
            } else {
                console.log('  🗑️ Test cihaz silindi');
            }
        }
    } catch (error) {
        console.error('  ❌ Test hatası:', error.message);
        return;
    }
    console.log('');
    
    // ═══════════════════════════════════════════════════════════════
    // SONUÇ
    // ═══════════════════════════════════════════════════════════════
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('✅ TÜM TESTLER BAŞARILI!');
    console.log('');
    console.log('📌 403 Hatası Analizi:');
    console.log('  Eğer buraya kadar geldiyseniz:');
    console.log('  → Supabase çalışıyor ✅');
    console.log('  → Evolution API çalışıyor ✅');
    console.log('  → 403 hatası form submit sırasında oluyor');
    console.log('');
    console.log('🔍 Sıradaki Adım:');
    console.log('  1. Form submit eventini debug edin');
    console.log('  2. Network tab\'ı açık tutun');
    console.log('  3. Hangi request 403 veriyor tespit edin');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
}

// Hemen çalıştır
debugWhatsAppDeviceAdd();
