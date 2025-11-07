/**
 * Firebase Data Export Script
 * Bu script Firebase'deki tüm verileri JSON formatında export eder
 * Supabase'e aktarım için kullanılır
 */

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Firebase Admin SDK başlatma
// serviceAccountKey.json dosyanızı Firebase Console'dan indirip buraya koyun
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Export edilecek koleksiyonlar
const COLLECTIONS = [
    'clubs',
    'settings',
    'users',
    'members',
    'preRegistrations',
    'groups',
    'schedules',
    'attendance',  // ✅ Firebase'de bu isimle tutuluyor
    'attendanceRecords',  // ✅ Yeni kayıtlar varsa
    'crmLeads',
    'crmTemplates',
    'whatsappDevices',
    'whatsappIncomingCalls',
    'whatsappIncomingMessages',
    'whatsappMessages',
    'sentMessages',
    'messageQueue',
    'scheduledMessages',
    'campaigns',
    'tasks',
    'expenses',
    'products',
    'webhooks',
    'userActivities',
    'holidays',
    'branches'
];

async function exportCollection(collectionName) {
    console.log(`\n📦 Exporting ${collectionName}...`);
    try {
        const snapshot = await db.collection(collectionName).get();
        const data = [];
        
        snapshot.forEach(doc => {
            data.push({
                id: doc.id,
                ...doc.data()
            });
        });
        
        console.log(`✅ Exported ${data.length} documents from ${collectionName}`);
        return data;
    } catch (error) {
        console.error(`❌ Error exporting ${collectionName}:`, error.message);
        return [];
    }
}

async function exportSubcollections() {
    console.log(`\n📦 Exporting subcollections (crmTags)...`);
    const crmTags = {};
    
    try {
        // Get all clubs first
        const clubsSnapshot = await db.collection('clubs').get();
        
        for (const clubDoc of clubsSnapshot.docs) {
            const clubId = clubDoc.id;
            const tagsSnapshot = await db.collection(`clubs/${clubId}/crmTags`).get();
            
            if (!tagsSnapshot.empty) {
                crmTags[clubId] = [];
                tagsSnapshot.forEach(doc => {
                    crmTags[clubId].push({
                        id: doc.id,
                        ...doc.data()
                    });
                });
                console.log(`✅ Exported ${crmTags[clubId].length} tags for club ${clubId}`);
            }
        }
    } catch (error) {
        console.error(`❌ Error exporting crmTags:`, error.message);
    }
    
    return crmTags;
}

async function main() {
    console.log('🚀 Firebase Data Export Started');
    console.log('================================\n');
    
    const exportData = {
        exportDate: new Date().toISOString(),
        collections: {}
    };
    
    // Export main collections
    for (const collectionName of COLLECTIONS) {
        exportData.collections[collectionName] = await exportCollection(collectionName);
    }
    
    // Export subcollections
    exportData.collections.crmTagsByClub = await exportSubcollections();
    
    // Create exports directory if it doesn't exist
    const exportDir = path.join(__dirname, 'exports');
    if (!fs.existsSync(exportDir)) {
        fs.mkdirSync(exportDir);
    }
    
    // Save to file
    const filename = `firebase-export-${Date.now()}.json`;
    const filepath = path.join(exportDir, filename);
    
    fs.writeFileSync(filepath, JSON.stringify(exportData, null, 2));
    
    console.log('\n================================');
    console.log('✅ Export completed successfully!');
    console.log(`📁 File saved to: ${filepath}`);
    
    // Print summary
    console.log('\n📊 Summary:');
    let totalDocs = 0;
    for (const [collection, data] of Object.entries(exportData.collections)) {
        if (collection === 'crmTagsByClub') {
            const tagCount = Object.values(data).reduce((sum, tags) => sum + tags.length, 0);
            console.log(`   ${collection}: ${tagCount} documents across ${Object.keys(data).length} clubs`);
            totalDocs += tagCount;
        } else {
            console.log(`   ${collection}: ${data.length} documents`);
            totalDocs += data.length;
        }
    }
    console.log(`\n📦 Total: ${totalDocs} documents exported`);
    
    process.exit(0);
}

// Run the export
main().catch(error => {
    console.error('❌ Fatal error:', error);
    process.exit(1);
});

