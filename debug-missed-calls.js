// 🔍 CEVAPSIZ ÇAĞRI OTOMATİK MESAJ DEBUG
// Console'a yapıştırın ve enter'a basın

console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
console.log('🔍 Cevapsız Çağrı Otomatik Mesaj Debug');
console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

// 1. WhatsApp cihazlarını kontrol et (GLOBAL ARRAY)
console.log('\n📱 WhatsApp Cihazları (Global Array):');
if (typeof whatsappDevices === 'undefined') {
    console.log('  ❌ whatsappDevices tanımlı değil!');
} else if (!whatsappDevices || whatsappDevices.length === 0) {
    console.log('  ⚠️ whatsappDevices boş!');
} else {
    console.log(`  ✅ ${whatsappDevices.length} cihaz bulundu:`);
    whatsappDevices.forEach((device, index) => {
        console.log(`  ${index + 1}. ${device.instanceName} - ${device.phoneNumber} (Status: ${device.status})`);
    });
}

// 2. Cevapsız çağrıları kontrol et
console.log('\n📞 Cevapsız Çağrılar:');
if (window.incomingCallsCategories) {
    const unanswered = window.incomingCallsCategories.unanswered || [];
    console.log(`  Toplam cevapsız çağrı: ${unanswered.length}`);
    
    if (unanswered.length > 0) {
        unanswered.forEach((call, index) => {
            console.log(`\n  ${index + 1}. Çağrı Detayı:`);
            console.log(`     Arayan: ${call.number}`);
            console.log(`     Aranan: ${call.lastCall?.callee || 'Bilinmiyor'}`);
            console.log(`     Tarih: ${call.lastCall?.call_time || 'Bilinmiyor'}`);
        });
    } else {
        console.log('  ℹ️ Cevapsız çağrı yok');
    }
} else {
    console.log('  ❌ incomingCallsCategories bulunamadı!');
}

// 3. CRM mesaj şablonunu kontrol et
console.log('\n📝 CRM Mesaj Şablonu:');
const customTemplates = JSON.parse(localStorage.getItem(`crmTemplates_${currentClubId}`) || '{}');
if (customTemplates['incoming-missed-call-template']) {
    console.log('  ✅ Şablon bulundu:');
    console.log(`  "${customTemplates['incoming-missed-call-template'].message.substring(0, 100)}..."`);
} else {
    console.log('  ⚠️ Özel şablon yok, varsayılan kullanılacak');
}

// 4. Bugün gönderilen mesajları kontrol et
console.log('\n📤 Bugün Gönderilen Mesajlar:');
const today = new Date().toLocaleDateString('tr-TR');
const todaySent = JSON.parse(localStorage.getItem(`autoReplySentToday_${currentClubId}_${today}`) || '{}');
const sentCount = Object.keys(todaySent).length;
console.log(`  Bugün ${sentCount} numaraya mesaj gönderildi`);
if (sentCount > 0) {
    Object.keys(todaySent).forEach(phone => {
        console.log(`    - ${phone}: ${todaySent[phone].deviceUsed || 'Bilinmiyor'}`);
    });
}

// 5. Fonksiyon kontrolü
console.log('\n🔧 Fonksiyon Durumu:');
if (typeof window.sendAutoReplyToNewMissedCalls !== 'function') {
    console.log('  ❌ window.sendAutoReplyToNewMissedCalls tanımlı değil!');
} else {
    console.log('  ✅ window.sendAutoReplyToNewMissedCalls fonksiyonu hazır');
}

// 6. Manuel test fonksiyonu
console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
console.log('🧪 Manuel test için şu komutu çalıştırın:');
console.log('   await window.sendAutoReplyToNewMissedCalls()');
console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
