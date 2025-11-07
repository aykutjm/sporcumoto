/**
 * 🔐 SUPERADMIN OLUŞTURMA ARACI
 * Supabase/Firebase'de superadmin/config belgesi oluşturur
 * ✅ Supabase & Firebase uyumlu - window.firebase API'si kullanır
 * 
 * Kullanım: Bu kodu tarayıcı console'una yapıştırın ve çalıştırın
 */

async function createSuperAdminConfig() {
    try {
        console.log('🔐 SuperAdmin yapılandırması oluşturuluyor...');
        console.log('');
        
        // Varsayılan bilgiler
        const defaultEmail = 'admin@superadmin.com';
        const defaultPassword = 'SuperAdmin2024!';
        
        // Kullanıcıdan bilgi al
        const email = prompt(
            '📧 SuperAdmin Email Adresi:\n\n' +
            `(Varsayılan: ${defaultEmail})\n\n` +
            'Email girin veya Enter\'a basın:',
            defaultEmail
        );
        
        if (!email) {
            console.log('❌ İşlem iptal edildi.');
            return;
        }
        
        const password = prompt(
            '🔒 SuperAdmin Şifre:\n\n' +
            `(Varsayılan: ${defaultPassword})\n\n` +
            'Şifre girin veya Enter\'a basın:',
            defaultPassword
        );
        
        if (!password) {
            console.log('❌ İşlem iptal edildi.');
            return;
        }
        
        console.log('');
        console.log('📝 Girilen bilgiler:');
        console.log('  Email:', email);
        console.log('  Şifre:', '*'.repeat(password.length));
        console.log('');
        
        // Onay al
        const confirm = window.confirm(
            '✅ Bilgiler doğru mu?\n\n' +
            `Email: ${email}\n` +
            `Şifre: ${password}\n\n` +
            'Oluşturmak için "Tamam"a basın.'
        );
        
        if (!confirm) {
            console.log('❌ İşlem iptal edildi.');
            return;
        }
        
        // Firebase'de oluştur
        console.log('🔥 Firebase\'de oluşturuluyor...');
        
        // Mevcut config'i kontrol et
        const docRef = window.firebase.doc(window.db, 'superadmin', 'config');
        const docSnap = await window.firebase.getDoc(docRef);
        
        if (docSnap.exists()) {
            const overwrite = confirm(
                '⚠️ UYARI!\n\n' +
                'SuperAdmin config zaten mevcut!\n\n' +
                'Mevcut bilgiler:\n' +
                `  Email: ${docSnap.data().email}\n\n` +
                'ÜZERİNE YAZMAK istiyor musunuz?'
            );
            
            if (!overwrite) {
                console.log('❌ İşlem iptal edildi.');
                console.log('ℹ️ Mevcut bilgiler korundu.');
                return;
            }
        }
        
        // Belgeyi oluştur/güncelle
        await window.firebase.setDoc(docRef, {
            email: email,
            password: password,
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString()
        });
        
        console.log('');
        console.log('🎉 SuperAdmin yapılandırması oluşturuldu!');
        console.log('');
        console.log('📋 GİRİŞ BİLGİLERİ:');
        console.log('─────────────────────────────────');
        console.log(`  📧 Email: ${email}`);
        console.log(`  🔒 Şifre: ${password}`);
        console.log('─────────────────────────────────');
        console.log('');
        console.log('✅ SuperAdmin paneline giriş yapabilirsiniz!');
        console.log('🔗 URL: /uyeyeni/superadmin.html');
        console.log('');
        
        // Kopyalamayı kolaylaştır
        console.log('📋 Bilgileri kopyalamak için:');
        console.log('');
        console.log(`Email: ${email}`);
        console.log(`Şifre: ${password}`);
        console.log('');
        
    } catch (error) {
        console.error('❌ Hata oluştu:', error);
        console.error('Detay:', error.message);
        console.error('');
        console.error('💡 İpucu: Firebase bağlantısını kontrol edin.');
    }
}

// Bilgilendirme
console.log('');
console.log('🔐 SUPERADMIN OLUŞTURMA ARACI HAZIR');
console.log('');
console.log('📝 Kullanım:');
console.log('   createSuperAdminConfig()');
console.log('');
console.log('⚠️  Not: Bu kodu admin.html veya superadmin.html sayfasında çalıştırın!');
console.log('');









