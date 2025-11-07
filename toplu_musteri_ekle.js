// ⚠️ Bu scripti admin.html sayfası açıkken tarayıcı console'unda (F12) çalıştırın!
// 📝 13 müşteriyi "Yetişkin Tenis - Denemeye Geldi" etiketiyle ekler
// ✅ Supabase & Firebase uyumlu - window.firebase API'si kullanır

(async function() {
    console.log('🚀 Toplu müşteri ekleme başlıyor...');
    
    // Müşteri listesi
    const customers = [
        { name: 'Yaren Yavuzyiğit-Semih Albayrak', phone: '05432127278' },
        { name: 'Meltem Kesim', phone: '05396643976' },
        { name: 'Hakan Şimşek - 3 Kişi', phone: '05416419140' },
        { name: 'Ahmet Kaya - 2 Kişi', phone: '05054699968' },
        { name: 'Ugurtan Yıldız - Büşra Akçay Yıldız', phone: '05439681133' },
        { name: 'Emine Hanım', phone: '05458438788' },
        { name: 'Leyla Sarı', phone: '05441521253' },
        { name: 'Namık Yıldırım', phone: '05386182716' },
        { name: 'Hülya Nur Oyman', phone: '05345704215' },
        { name: 'Cansu Kumaş - 3 Kişi', phone: '05455876415' },
        { name: 'Ayfer Gözükara', phone: '05301856457' },
        { name: 'Merve Aydın', phone: '05314204114' },
        { name: 'Gökhan Coşkuner - 4 Kişi', phone: '05442414384' }
    ];
    
    // Yetişkin Tenis branşını bul
    const tenisBranch = branches.find(b => b.name && b.name.toLowerCase().includes('tenis'));
    
    if (!tenisBranch) {
        console.error('❌ Yetişkin Tenis branşı bulunamadı!');
        console.log('📋 Mevcut branşlar:', branches.map(b => b.name).join(', '));
        return;
    }
    
    console.log(`✅ Branş bulundu: ${tenisBranch.name} (ID: ${tenisBranch.id})`);
    
    const now = new Date();
    const dateStr = now.toLocaleString('tr-TR', { 
        day: '2-digit', 
        month: '2-digit', 
        year: 'numeric', 
        hour: '2-digit', 
        minute: '2-digit' 
    });
    const userName = currentUser.fullName || currentUser.email || 'Admin';
    
    let successCount = 0;
    let errorCount = 0;
    
    for (const customer of customers) {
        try {
            // Aynı telefon numarası var mı kontrol et
            const existingLead = crmLeads.find(l => 
                l.phone && customer.phone && 
                l.phone.replace(/\D/g, '') === customer.phone.replace(/\D/g, '')
            );
            
            if (existingLead) {
                console.warn(`⚠️ Atlandı: ${customer.name} - Bu telefon zaten kayıtlı (${existingLead.fullName})`);
                errorCount++;
                continue;
            }
            
            // Lead verisi oluştur
            const leadData = {
                fullName: customer.name,
                phone: customer.phone,
                source: 'phone',
                clubId: currentClubId,
                createdAt: now.toISOString(),
                createdBy: userName,
                status: 'new',
                branches: [{
                    branchId: tenisBranch.id,
                    branchName: tenisBranch.name,
                    ageGroup: 'adult',
                    selectedTag: 'Denemeye Geldi',
                    fullName: customer.name,
                    notesHistory: [],
                    kayitOlabilirDate: null,
                    denemeDate: null
                }],
                history: [
                    {
                        action: 'created',
                        by: userName,
                        date: dateStr,
                        details: `Müşteri oluşturuldu - ${customer.name} (${customer.phone})`
                    },
                    {
                        action: 'tag_added',
                        by: userName,
                        date: dateStr,
                        details: `${tenisBranch.name} - Etiket: "Denemeye Geldi"`
                    }
                ]
            };
            
            // Firebase'e ekle
            const docRef = await window.firebase.addDoc(
                window.firebase.collection(window.db, 'crmLeads'),
                leadData
            );
            
            console.log(`✅ Eklendi: ${customer.name} (${customer.phone}) - ID: ${docRef.id}`);
            successCount++;
            
            // Rate limiting için kısa bekleme
            await new Promise(resolve => setTimeout(resolve, 500));
            
        } catch (error) {
            console.error(`❌ Hata: ${customer.name} eklenirken sorun oluştu:`, error);
            errorCount++;
        }
    }
    
    console.log('\n📊 ÖZET:');
    console.log(`✅ Başarılı: ${successCount} müşteri`);
    console.log(`❌ Hata/Atlandı: ${errorCount} müşteri`);
    console.log('\n🔄 Sayfayı yenileyerek yeni müşterileri görebilirsiniz.');
    
    // Sayfayı otomatik yenile
    if (successCount > 0) {
        console.log('⏳ 3 saniye içinde sayfa yenilenecek...');
        setTimeout(() => {
            location.reload();
        }, 3000);
    }
})();

