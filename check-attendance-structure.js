/**
 * Firebase'de attendance kayıtlarının yapısını kontrol eden script
 */

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function checkAttendanceStructure() {
    console.log('🔍 Attendance kayıtlarının yapısı kontrol ediliyor...\n');
    
    try {
        // 1. Top-level attendanceRecords collection'ı kontrol et
        console.log('📦 Checking top-level "attendanceRecords" collection:');
        const attendanceSnapshot = await db.collection('attendanceRecords').limit(5).get();
        console.log(`   Found: ${attendanceSnapshot.size} documents (showing first 5)`);
        if (!attendanceSnapshot.empty) {
            console.log('   Sample document:');
            console.log(JSON.stringify(attendanceSnapshot.docs[0].data(), null, 2));
        }
        
        // 2. Top-level "attendance" collection'ı kontrol et (eski isim olabilir)
        console.log('\n📦 Checking top-level "attendance" collection:');
        const attendanceOldSnapshot = await db.collection('attendance').limit(5).get();
        console.log(`   Found: ${attendanceOldSnapshot.size} documents (showing first 5)`);
        if (!attendanceOldSnapshot.empty) {
            console.log('   Sample document:');
            console.log(JSON.stringify(attendanceOldSnapshot.docs[0].data(), null, 2));
        }
        
        // 3. Members altında subcollection olarak kontrol et
        console.log('\n📦 Checking subcollections under members:');
        const membersSnapshot = await db.collection('members').limit(3).get();
        console.log(`   Checking ${membersSnapshot.size} members for subcollections...`);
        
        for (const memberDoc of membersSnapshot.docs) {
            const subcollections = await db.collection(`members/${memberDoc.id}/attendanceRecords`).limit(2).get();
            if (!subcollections.empty) {
                console.log(`   ✅ Found attendanceRecords under member ${memberDoc.id}: ${subcollections.size} records`);
                console.log('   Sample document:');
                console.log(JSON.stringify(subcollections.docs[0].data(), null, 2));
                break; // İlk bulduğumuzda dur
            }
        }
        
        // 4. Groups altında subcollection olarak kontrol et
        console.log('\n📦 Checking subcollections under groups:');
        const groupsSnapshot = await db.collection('groups').limit(3).get();
        console.log(`   Checking ${groupsSnapshot.size} groups for subcollections...`);
        
        for (const groupDoc of groupsSnapshot.docs) {
            const subcollections = await db.collection(`groups/${groupDoc.id}/attendanceRecords`).limit(2).get();
            if (!subcollections.empty) {
                console.log(`   ✅ Found attendanceRecords under group ${groupDoc.id}: ${subcollections.size} records`);
                console.log('   Sample document:');
                console.log(JSON.stringify(subcollections.docs[0].data(), null, 2));
                break;
            }
            
            // Ayrıca attendance adıyla da kontrol et
            const subcollections2 = await db.collection(`groups/${groupDoc.id}/attendance`).limit(2).get();
            if (!subcollections2.empty) {
                console.log(`   ✅ Found attendance under group ${groupDoc.id}: ${subcollections2.size} records`);
                console.log('   Sample document:');
                console.log(JSON.stringify(subcollections2.docs[0].data(), null, 2));
                break;
            }
        }
        
        // 5. Schedules altında kontrol et
        console.log('\n📦 Checking subcollections under schedules:');
        const schedulesSnapshot = await db.collection('schedules').limit(3).get();
        console.log(`   Checking ${schedulesSnapshot.size} schedules for subcollections...`);
        
        for (const scheduleDoc of schedulesSnapshot.docs) {
            const subcollections = await db.collection(`schedules/${scheduleDoc.id}/attendanceRecords`).limit(2).get();
            if (!subcollections.empty) {
                console.log(`   ✅ Found attendanceRecords under schedule ${scheduleDoc.id}: ${subcollections.size} records`);
                console.log('   Sample document:');
                console.log(JSON.stringify(subcollections.docs[0].data(), null, 2));
                break;
            }
        }
        
        console.log('\n✅ Kontrol tamamlandı!');
        
    } catch (error) {
        console.error('❌ Hata:', error);
    }
    
    process.exit(0);
}

checkAttendanceStructure();

