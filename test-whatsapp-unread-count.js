// 🔍 WHATSAPP OKUNMAMIŞ MESAJ SAYISI DEBUG
// Console'a yapıştırın ve çalıştırın

console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
console.log('🔍 WhatsApp Okunmamış Mesaj Sayısı Debug');
console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

// 1. Global değişkenleri kontrol et
console.log('\n📊 GLOBAL DEĞİŞKENLER:');
console.log('  lastWhatsAppUnreadCount:', lastWhatsAppUnreadCount);
console.log('  whatsappContacts.length:', whatsappContacts?.length || 0);

// 2. Toplam okunmamış sayısını hesapla
const currentUnread = whatsappContacts?.reduce((sum, c) => sum + (c.unreadCount || 0), 0) || 0;
console.log('  Toplam okunmamış:', currentUnread);

// 3. Okunmamış mesajı olan kişileri listele
console.log('\n📬 OKUNMAMIŞ MESAJI OLAN KİŞİLER:');
const unreadContacts = whatsappContacts?.filter(c => c.unreadCount > 0) || [];
if (unreadContacts.length === 0) {
    console.log('  ✅ Hiç okunmamış mesaj yok');
} else {
    unreadContacts.forEach(c => {
        console.log(`  - ${c.name} (${c.phone}): ${c.unreadCount} okunmamış`);
        console.log(`    Son mesaj: ${c.lastMessage?.substring(0, 50) || 'Yok'}`);
        console.log(`    Son mesaj zamanı: ${new Date(c.lastMessageTime).toLocaleString()}`);
        console.log(`    Bizden mi: ${c.lastMessageFromMe ? 'Evet' : 'Hayır'}`);
    });
}

// 4. localStorage okundu bilgilerini kontrol et
console.log('\n💾 LOCALSTORAGE OKUNDU BİLGİLERİ:');
const storageKey = 'whatsapp_read_messages_' + currentClubId;
const readContacts = JSON.parse(localStorage.getItem(storageKey) || '{}');
console.log(`  Kayıtlı okundu bilgisi: ${Object.keys(readContacts).length} kişi`);

unreadContacts.forEach(c => {
    const lastReadTime = readContacts[c.phone];
    if (lastReadTime) {
        const lastReadDate = new Date(lastReadTime);
        const lastMessageDate = new Date(c.lastMessageTime);
        const isNewer = lastMessageDate > lastReadDate;
        
        console.log(`\n  ${c.name} (${c.phone}):`);
        console.log(`    Son okunma: ${lastReadDate.toLocaleString()}`);
        console.log(`    Son mesaj:  ${lastMessageDate.toLocaleString()}`);
        console.log(`    Mesaj daha yeni mi: ${isNewer ? '✅ Evet (okunmamış sayılmalı)' : '❌ Hayır (okunmuş sayılmalı)'}`);
    } else {
        console.log(`\n  ${c.name} (${c.phone}):`);
        console.log(`    ⚠️ Hiç okunmamış (localStorage'da kayıt yok)`);
    }
});

// 5. Test önerileri
console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
console.log('🧪 TEST ÖNERİLERİ:');

if (currentUnread !== lastWhatsAppUnreadCount && lastWhatsAppUnreadCount !== -1) {
    console.log(`  ⚠️ UYARI: Sayaç tutarsız!`);
    console.log(`     lastWhatsAppUnreadCount: ${lastWhatsAppUnreadCount}`);
    console.log(`     Gerçek okunmamış: ${currentUnread}`);
    console.log(`     → updateWhatsAppUnreadCount() çağrılmalı`);
}

if (unreadContacts.length > 0) {
    console.log(`  1️⃣ Bir konuşma açın ve kapatın, sonra bu scripti tekrar çalıştırın`);
    console.log(`  2️⃣ Console'da şu logları arayın:`);
    console.log(`     - "📖 Konuşma açıldı"`);
    console.log(`     - "📊 WhatsApp okunmamış mesaj sayısı güncellendi"`);
    console.log(`     - "✅ Konuşma okundu olarak işaretlendi"`);
}

// 6. Manuel düzeltme fonksiyonları
console.log('\n🔧 MANUEL DÜZELTME:');
console.log('  localStorage temizle:');
console.log(`    localStorage.removeItem('${storageKey}')`);
console.log('\n  Tüm okunmamışları sıfırla:');
console.log(`    whatsappContacts.forEach(c => c.unreadCount = 0); updateWhatsAppUnreadCount();`);
console.log('\n  Belirli bir kişiyi okundu yap:');
console.log(`    markContactAsRead('905449367543');`);

console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
console.log('✅ Debug tamamlandı!');
console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
