// 🔧 SIKIŞMIŞ NUMARAYI DÜZELT
// Console'a yapıştırın ve enter'a basın

console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
console.log('🔧 Sıkışmış Numara Düzeltme');
console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

// 1. Problematik numarayı temizle
const problemNumber = '05333011994';
const storageKey = `otherCalls_${currentClubId}`;
const otherCallsStorage = JSON.parse(localStorage.getItem(storageKey) || '{}');

console.log(`\n📋 Mevcut "Diğer" kategorisindeki numaralar:`, Object.keys(otherCallsStorage));

if (otherCallsStorage[problemNumber]) {
    delete otherCallsStorage[problemNumber];
    localStorage.setItem(storageKey, JSON.stringify(otherCallsStorage));
    console.log(`✅ ${problemNumber} "Diğer" kategorisinden kaldırıldı`);
} else {
    console.log(`⚠️ ${problemNumber} "Diğer" kategorisinde bulunamadı`);
}

// 2. Sayfayı yenile
console.log('\n🔄 3 saniye sonra sayfa yenilenecek...');
console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

setTimeout(() => {
    console.log('🔄 Sayfa yenileniyor...');
    location.reload();
}, 3000);
