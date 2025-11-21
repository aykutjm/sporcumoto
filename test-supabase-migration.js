/**
 * Otomatik Test Script - Supabase Migration
 * Tests: Data Loading, Accounting Module, WhatsApp Module
 */

const testResults = {
    passed: [],
    failed: [],
    warnings: []
};

// Test 1: Supabase Connection
async function testSupabaseConnection() {
    console.log('\n🧪 TEST 1: Supabase Bağlantısı');
    try {
        if (!window.supabase) {
            throw new Error('Supabase client bulunamadı');
        }
        
        const { data, error } = await window.supabase
            .from('clubs')
            .select('id')
            .limit(1);
        
        if (error) throw error;
        
        testResults.passed.push('✅ Supabase bağlantısı başarılı');
        console.log('✅ PASSED: Supabase bağlantısı çalışıyor');
        return true;
    } catch (error) {
        testResults.failed.push(`❌ Supabase bağlantı hatası: ${error.message}`);
        console.error('❌ FAILED:', error);
        return false;
    }
}

// Test 2: Data Loading (loadData function)
async function testDataLoading() {
    console.log('\n🧪 TEST 2: loadData() Fonksiyonu');
    try {
        const clubId = localStorage.getItem('selectedClubId');
        if (!clubId) {
            throw new Error('Club ID bulunamadı');
        }
        
        // Test groups loading
        const { data: groups, error: groupsError } = await window.supabase
            .from('groups')
            .select('*')
            .eq('clubId', clubId);
        
        if (groupsError) throw new Error(`Groups yükleme hatası: ${groupsError.message}`);
        
        // Test members loading
        const { data: members, error: membersError } = await window.supabase
            .from('members')
            .select('*')
            .eq('clubId', clubId);
        
        if (membersError) throw new Error(`Members yükleme hatası: ${membersError.message}`);
        
        // Test whatsappDevices loading
        const { data: devices, error: devicesError } = await window.supabase
            .from('whatsappDevices')
            .select('*')
            .eq('clubId', clubId);
        
        if (devicesError) throw new Error(`WhatsApp devices yükleme hatası: ${devicesError.message}`);
        
        testResults.passed.push(`✅ Groups yüklendi: ${groups.length} adet`);
        testResults.passed.push(`✅ Members yüklendi: ${members.length} adet`);
        testResults.passed.push(`✅ WhatsApp Devices yüklendi: ${devices.length} adet`);
        
        console.log('✅ PASSED: Tüm veriler Supabase\'den başarıyla yüklendi');
        console.log(`   - Groups: ${groups.length}`);
        console.log(`   - Members: ${members.length}`);
        console.log(`   - WhatsApp Devices: ${devices.length}`);
        
        return true;
    } catch (error) {
        testResults.failed.push(`❌ Data loading hatası: ${error.message}`);
        console.error('❌ FAILED:', error);
        return false;
    }
}

// Test 3: sentMessages Column Fix
async function testSentMessagesColumn() {
    console.log('\n🧪 TEST 3: sentMessages Tablo Yapısı (sentAt column)');
    try {
        const clubId = localStorage.getItem('selectedClubId');
        
        const { data, error } = await window.supabase
            .from('sentMessages')
            .select('*')
            .eq('clubId', clubId)
            .order('sentAt', { ascending: false })
            .limit(5);
        
        if (error) throw error;
        
        // Check if sentAt column exists in returned data
        if (data.length > 0 && !data[0].hasOwnProperty('sentAt')) {
            throw new Error('sentAt kolonu bulunamadı');
        }
        
        testResults.passed.push(`✅ sentMessages.sentAt kolonu çalışıyor: ${data.length} mesaj`);
        console.log('✅ PASSED: sentMessages tablosu sentAt kolonu ile çalışıyor');
        console.log(`   - Yüklenen mesaj sayısı: ${data.length}`);
        
        return true;
    } catch (error) {
        testResults.failed.push(`❌ sentMessages hatası: ${error.message}`);
        console.error('❌ FAILED:', error);
        return false;
    }
}

// Test 4: Accounting Module - Expenses
async function testExpensesModule() {
    console.log('\n🧪 TEST 4: Muhasebe - Giderler Modülü');
    try {
        const clubId = localStorage.getItem('selectedClubId');
        
        // Test expenses loading
        const { data: expenses, error: loadError } = await window.supabase
            .from('expenses')
            .select('*')
            .eq('clubId', clubId);
        
        if (loadError) throw new Error(`Gider yükleme hatası: ${loadError.message}`);
        
        // Test add expense (create test expense)
        const testExpense = {
            clubId: clubId,
            category: 'TEST',
            description: 'Otomatik Test Gideri',
            amount: 1,
            branch: 'Test',
            date: new Date().toISOString().split('T')[0],
            createdBy: 'Test Script',
            createdAt: new Date().toISOString()
        };
        
        const { data: addedExpense, error: addError } = await window.supabase
            .from('expenses')
            .insert(testExpense)
            .select();
        
        if (addError) throw new Error(`Gider ekleme hatası: ${addError.message}`);
        
        const expenseId = addedExpense[0].id;
        
        // Test delete expense
        const { error: deleteError } = await window.supabase
            .from('expenses')
            .delete()
            .eq('id', expenseId);
        
        if (deleteError) throw new Error(`Gider silme hatası: ${deleteError.message}`);
        
        testResults.passed.push(`✅ Expenses READ: ${expenses.length} gider yüklendi`);
        testResults.passed.push('✅ Expenses WRITE: Test gider eklendi');
        testResults.passed.push('✅ Expenses DELETE: Test gider silindi');
        
        console.log('✅ PASSED: Giderler modülü tam çalışıyor');
        console.log(`   - Toplam gider: ${expenses.length}`);
        console.log(`   - Test gider ID: ${expenseId}`);
        
        return true;
    } catch (error) {
        testResults.failed.push(`❌ Expenses modülü hatası: ${error.message}`);
        console.error('❌ FAILED:', error);
        return false;
    }
}

// Test 5: Accounting Module - Products
async function testProductsModule() {
    console.log('\n🧪 TEST 5: Muhasebe - Ürünler Modülü');
    try {
        const clubId = localStorage.getItem('selectedClubId');
        
        // Test products loading
        const { data: products, error: loadError } = await window.supabase
            .from('products')
            .select('*')
            .eq('clubId', clubId);
        
        if (loadError) throw new Error(`Ürün yükleme hatası: ${loadError.message}`);
        
        // Test add product
        const testProduct = {
            clubId: clubId,
            name: 'Test Ürün',
            category: 'TEST',
            costPrice: 1,
            price: 2,
            stock: 1,
            branch: 'Test',
            createdBy: 'Test Script',
            createdAt: new Date().toISOString()
        };
        
        const { data: addedProduct, error: addError } = await window.supabase
            .from('products')
            .insert(testProduct)
            .select();
        
        if (addError) throw new Error(`Ürün ekleme hatası: ${addError.message}`);
        
        const productId = addedProduct[0].id;
        
        // Test delete product
        const { error: deleteError } = await window.supabase
            .from('products')
            .delete()
            .eq('id', productId);
        
        if (deleteError) throw new Error(`Ürün silme hatası: ${deleteError.message}`);
        
        testResults.passed.push(`✅ Products READ: ${products.length} ürün yüklendi`);
        testResults.passed.push('✅ Products WRITE: Test ürün eklendi');
        testResults.passed.push('✅ Products DELETE: Test ürün silindi');
        
        console.log('✅ PASSED: Ürünler modülü tam çalışıyor');
        console.log(`   - Toplam ürün: ${products.length}`);
        console.log(`   - Test ürün ID: ${productId}`);
        
        return true;
    } catch (error) {
        testResults.failed.push(`❌ Products modülü hatası: ${error.message}`);
        console.error('❌ FAILED:', error);
        return false;
    }
}

// Test 6: WhatsApp Devices Loading
async function testWhatsAppDevices() {
    console.log('\n🧪 TEST 6: WhatsApp Cihazları');
    try {
        const clubId = localStorage.getItem('selectedClubId');
        
        const { data: devices, error } = await window.supabase
            .from('whatsappDevices')
            .select('*')
            .eq('clubId', clubId);
        
        if (error) throw error;
        
        // Check if global variables are set
        if (!window.whatsappDevices) {
            testResults.warnings.push('⚠️ window.whatsappDevices global değişkeni boş');
        }
        
        if (!window.selectedWhatsAppDevice && !window.defaultWhatsAppDevice) {
            testResults.warnings.push('⚠️ Hiç WhatsApp cihazı seçili değil');
        }
        
        testResults.passed.push(`✅ WhatsApp Devices: ${devices.length} cihaz yüklendi`);
        
        console.log('✅ PASSED: WhatsApp cihazları başarıyla yüklendi');
        console.log(`   - Toplam cihaz: ${devices.length}`);
        if (window.selectedWhatsAppDevice) {
            console.log(`   - Seçili cihaz: ${window.selectedWhatsAppDevice.instanceName}`);
        }
        
        return true;
    } catch (error) {
        testResults.failed.push(`❌ WhatsApp devices hatası: ${error.message}`);
        console.error('❌ FAILED:', error);
        return false;
    }
}

// Test 7: Message Queue
async function testMessageQueue() {
    console.log('\n🧪 TEST 7: WhatsApp Mesaj Kuyruğu');
    try {
        const clubId = localStorage.getItem('selectedClubId');
        
        const { data: messages, error } = await window.supabase
            .from('sentMessages')
            .select('*')
            .eq('clubId', clubId)
            .eq('status', 'pending')
            .order('sentAt', { ascending: false });
        
        if (error) throw error;
        
        testResults.passed.push(`✅ Message Queue: ${messages.length} bekleyen mesaj`);
        
        console.log('✅ PASSED: Mesaj kuyruğu başarıyla yüklendi');
        console.log(`   - Bekleyen mesaj: ${messages.length}`);
        
        return true;
    } catch (error) {
        testResults.failed.push(`❌ Message queue hatası: ${error.message}`);
        console.error('❌ FAILED:', error);
        return false;
    }
}

// Test 8: CRM Leads (still Firebase - should detect this)
async function testCRMCompatibility() {
    console.log('\n🧪 TEST 8: CRM Modülü Uyumluluk');
    try {
        const clubId = localStorage.getItem('selectedClubId');
        
        // Check if crmLeads are loaded (from loadData)
        const { data: leads, error } = await window.supabase
            .from('crmLeads')
            .select('*')
            .eq('clubId', clubId)
            .limit(5);
        
        if (error) throw error;
        
        testResults.passed.push(`✅ CRM Leads READ: ${leads.length} lead yüklendi (Supabase)`);
        testResults.warnings.push('⚠️ CRM WRITE fonksiyonları henüz Firebase kullanıyor');
        
        console.log('✅ PASSED: CRM Leads Supabase\'den okunuyor');
        console.log('⚠️ WARNING: CRM WRITE işlemleri henüz migrate edilmedi');
        
        return true;
    } catch (error) {
        testResults.failed.push(`❌ CRM hatası: ${error.message}`);
        console.error('❌ FAILED:', error);
        return false;
    }
}

// Run All Tests
async function runAllTests() {
    console.log('🚀 SUPABASE MİGRASYON OTOMATİK TEST BAŞLIYOR...\n');
    console.log('='.repeat(60));
    
    const startTime = Date.now();
    
    const tests = [
        testSupabaseConnection,
        testDataLoading,
        testSentMessagesColumn,
        testExpensesModule,
        testProductsModule,
        testWhatsAppDevices,
        testMessageQueue,
        testCRMCompatibility
    ];
    
    for (const test of tests) {
        await test();
    }
    
    const endTime = Date.now();
    const duration = ((endTime - startTime) / 1000).toFixed(2);
    
    // Print Summary
    console.log('\n' + '='.repeat(60));
    console.log('📊 TEST SONUÇLARI');
    console.log('='.repeat(60));
    
    console.log(`\n✅ BAŞARILI (${testResults.passed.length}):`);
    testResults.passed.forEach(msg => console.log(`   ${msg}`));
    
    if (testResults.warnings.length > 0) {
        console.log(`\n⚠️ UYARILAR (${testResults.warnings.length}):`);
        testResults.warnings.forEach(msg => console.log(`   ${msg}`));
    }
    
    if (testResults.failed.length > 0) {
        console.log(`\n❌ BAŞARISIZ (${testResults.failed.length}):`);
        testResults.failed.forEach(msg => console.log(`   ${msg}`));
    }
    
    console.log(`\n⏱️ Toplam Süre: ${duration} saniye`);
    console.log('='.repeat(60));
    
    // Final verdict
    if (testResults.failed.length === 0) {
        console.log('\n🎉 TÜM TESTLER BAŞARILI!');
        console.log('✅ Supabase migration çalışıyor');
    } else {
        console.log(`\n⚠️ ${testResults.failed.length} TEST BAŞARISIZ`);
        console.log('❌ Lütfen hataları kontrol edin');
    }
    
    return {
        passed: testResults.passed.length,
        failed: testResults.failed.length,
        warnings: testResults.warnings.length,
        duration: duration
    };
}

// Auto-run if loaded in browser
if (typeof window !== 'undefined') {
    console.log('✅ Test script yüklendi. Çalıştırmak için: runAllTests()');
}
