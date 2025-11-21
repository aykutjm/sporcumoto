// 🔧 WHATSAPP OKUNMAMIŞ SAYAC SIFIRLAMA
// Console'a yapıştırın ve enter'a basın

console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
console.log('🔧 WhatsApp Okunmamış Sayaç Sıfırlama');
console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

// 1. Mevcut durumu göster
console.log('\n📊 Mevcut Durum:');
const currentTotal = whatsappContacts?.reduce((sum, c) => sum + (c.unreadCount || 0), 0) || 0;
console.log(`  Toplam okunmamış: ${currentTotal}`);
console.log(`  lastWhatsAppUnreadCount: ${lastWhatsAppUnreadCount}`);

// 2. localStorage'ı temizle
const storageKey = 'whatsapp_read_messages_' + currentClubId;
const oldData = localStorage.getItem(storageKey);
localStorage.removeItem(storageKey);
console.log('\n🗑️ localStorage temizlendi');
console.log(`  Eski veri: ${oldData ? Object.keys(JSON.parse(oldData)).length + ' kişi' : 'Yoktu'}`);

// 3. Tüm kontakları şu anda "okundu" olarak işaretle
whatsappContacts?.forEach(c => {
    if (c.unreadCount > 0) {
        console.log(`  ✅ ${c.name} (${c.phone}) okundu olarak işaretlendi`);
        markContactAsRead(c.phone);
    }
});

console.log('\n✅ Tamamlandı!');
console.log('  → Tüm mesajlar okundu olarak işaretlendi');
console.log('  → 3 saniye sonra sayfa yenilenecek...');
console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

// Sayfa yenileme
setTimeout(() => {
    console.log('🔄 Sayfa yenileniyor...');
    location.reload();
}, 3000);

