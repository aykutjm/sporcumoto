/**
 * Sadece attendance kayıtlarını import eden script
 */

const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');
const path = require('path');

const SUPABASE_URL = 'https://supabase.edu-ai.online';
const SUPABASE_SERVICE_KEY = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzdXBhYmFzZSIsImlhdCI6MTc2MjEwNTMyMCwiZXhwIjo0OTE3Nzc4OTIwLCJyb2xlIjoiYW5vbiJ9.HXUza0GT82-trWkx0WWKe-nY7KsGrIjIHSOJPKsOHjs';

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

// Firebase timestamp'lerini temizle
function cleanData(obj) {
    const cleaned = { ...obj };
    for (const key in cleaned) {
        const value = cleaned[key];
        if (value && typeof value === 'object' && value._seconds !== undefined) {
            cleaned[key] = new Date(value._seconds * 1000).toISOString();
        } else if (value === '' && (key.includes('date') || key.includes('Date') || key.includes('At') || key.includes('time') || key.includes('Time'))) {
            cleaned[key] = null;
        } else if (value === 'default' || value === 'granted' || value === 'denied') {
            if (key.toLowerCase().includes('permission') || key.toLowerCase().includes('status')) {
                cleaned[key] = value === 'granted';
            }
        }
    }
    return cleaned;
}

async function importAttendance() {
    console.log('🚀 Attendance kayıtları import ediliyor...\n');
    
    // En son export dosyasını bul
    const exportDir = path.join(__dirname, 'exports');
    const files = fs.readdirSync(exportDir)
        .filter(f => f.startsWith('firebase-export-') && f.endsWith('.json'))
        .sort()
        .reverse();
    
    const exportFile = path.join(exportDir, files[0]);
    console.log(`📂 Reading from: ${exportFile}\n`);
    
    const exportData = JSON.parse(fs.readFileSync(exportFile, 'utf8'));
    const attendance = exportData.collections.attendance || [];
    
    console.log(`📊 Toplam ${attendance.length} attendance kaydı bulundu\n`);
    
    if (attendance.length === 0) {
        console.log('❌ Attendance kaydı bulunamadı!');
        process.exit(0);
    }
    
    // 1. Mevcut kayıtları sil
    console.log('🗑️  Mevcut attendanceRecords kayıtları siliniyor...');
    const { error: deleteError } = await supabase
        .from('attendanceRecords')
        .delete()
        .neq('id', ''); // Tüm kayıtları sil
    
    if (deleteError) {
        console.log(`⚠️  Silme hatası (normal olabilir): ${deleteError.message}`);
    } else {
        console.log('✅ Mevcut kayıtlar silindi\n');
    }
    
    // 2. Yeni kayıtları ekle (batch halinde)
    console.log('📥 Yeni kayıtlar ekleniyor...');
    const batchSize = 100;
    let successCount = 0;
    let errorCount = 0;
    
    for (let i = 0; i < attendance.length; i += batchSize) {
        const batch = attendance.slice(i, i + batchSize);
        const cleanedBatch = batch.map(cleanData);
        
        const { data, error } = await supabase
            .from('attendanceRecords')
            .insert(cleanedBatch);
        
        if (error) {
            console.error(`❌ Batch ${i}-${i + batch.length} hatası:`, error.message);
            errorCount += batch.length;
        } else {
            successCount += batch.length;
            console.log(`✅ ${i + batch.length}/${attendance.length} kaydedildi`);
        }
    }
    
    console.log('\n================================');
    console.log(`✅ Import tamamlandı!`);
    console.log(`📊 ${successCount} başarılı, ${errorCount} hata`);
    
    process.exit(0);
}

importAttendance().catch(error => {
    console.error('❌ Fatal error:', error);
    process.exit(1);
});

