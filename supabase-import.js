/**
 * Supabase Data Import Script
 * Firebase'den export edilen verileri Supabase'e import eder
 */

const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');
const path = require('path');

// Supabase configuration
const SUPABASE_URL = 'https://supabase.edu-ai.online';
const SUPABASE_SERVICE_KEY = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzdXBhYmFzZSIsImlhdCI6MTc2MjEwNTMyMCwiZXhwIjo0OTE3Nzc4OTIwLCJyb2xlIjoiYW5vbiJ9.HXUza0GT82-trWkx0WWKe-nY7KsGrIjIHSOJPKsOHjs'; // Anon key kullanıyoruz (RLS kapalı)

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

// Field mapping from Firebase to Supabase (snake_case conversion)
const FIELD_MAPPINGS = {
    clubName: 'club_name',
    clubId: 'club_id',
    adminEmail: 'admin_email',
    adminPhone: 'admin_phone',
    adminName: 'admin_name',
    memberCount: 'member_count',
    createdAt: 'created_at',
    updatedAt: 'updated_at',
    fullName: 'full_name',
    birthDate: 'birth_date',
    parent1Name: 'parent1_name',
    parent1Phone: 'parent1_phone',
    parent2Name: 'parent2_name',
    parent2Phone: 'parent2_phone',
    membershipType: 'membership_type',
    registrationDate: 'registration_date',
    paymentStatus: 'payment_status',
    paymentAmount: 'payment_amount',
    paymentFrequency: 'payment_frequency',
    lastPaymentDate: 'last_payment_date',
    nextPaymentDate: 'next_payment_date',
    isActive: 'is_active',
    minWaitTime: 'min_wait_time',
    maxWaitTime: 'max_wait_time',
    longWaitTrigger: 'long_wait_trigger',
    minLongWait: 'min_long_wait',
    maxLongWait: 'max_long_wait',
    phoneNumber: 'phone_number',
    callerName: 'caller_name',
    callTime: 'call_time',
    isAnswered: 'is_answered',
    isDeleted: 'is_deleted',
    isHidden: 'is_hidden',
    convertedToLead: 'converted_to_lead',
    leadId: 'lead_id',
    fromNumber: 'from_number',
    toNumber: 'to_number',
    messageText: 'message_text',
    messageType: 'message_type',
    mediaUrl: 'media_url',
    isRead: 'is_read',
    webhookData: 'webhook_data',
    deviceId: 'device_id',
    sentAt: 'sent_at',
    deliveredAt: 'delivered_at',
    errorMessage: 'error_message',
    deviceName: 'device_name',
    apiKey: 'api_key',
    apiUrl: 'api_url',
    isDefault: 'is_default',
    lastConnected: 'last_connected',
    recipientPhone: 'recipient_phone',
    recipientName: 'recipient_name',
    sentBy: 'sent_by',
    scheduledAt: 'scheduled_at',
    retryCount: 'retry_count',
    maxRetries: 'max_retries',
    scheduledFor: 'scheduled_for',
    createdBy: 'created_by',
    campaignName: 'campaign_name',
    targetAudience: 'target_audience',
    recipientCount: 'recipient_count',
    sentCount: 'sent_count',
    startedAt: 'started_at',
    completedAt: 'completed_at',
    dueDate: 'due_date',
    assignedTo: 'assigned_to',
    expenseDate: 'expense_date',
    paymentMethod: 'payment_method',
    receiptUrl: 'receipt_url',
    recordedBy: 'recorded_by',
    productName: 'product_name',
    stockQuantity: 'stock_quantity',
    webhookUrl: 'webhook_url',
    webhookType: 'webhook_type',
    lastTriggered: 'last_triggered',
    activityType: 'activity_type',
    entityType: 'entity_type',
    entityId: 'entity_id',
    ipAddress: 'ip_address',
    userAgent: 'user_agent',
    holidayName: 'holiday_name',
    startDate: 'start_date',
    endDate: 'end_date',
    branchName: 'branch_name',
    memberId: 'member_id',
    groupId: 'group_id',
    dayOfWeek: 'day_of_week',
    startTime: 'start_time',
    endTime: 'end_time',
    ageGroup: 'age_group',
    maxCapacity: 'max_capacity',
    currentCount: 'current_count',
    scheduleDays: 'schedule_days',
    scheduleTimes: 'schedule_times',
    attendanceDate: 'attendance_date',
    scheduleId: 'schedule_id',
    lastLogin: 'last_login',
    passwordHash: 'password_hash',
    parentName: 'parent_name',
    parentPhone: 'parent_phone',
    lastContactDate: 'last_contact_date',
    nextFollowUpDate: 'next_follow_up_date',
    convertedToMemberId: 'converted_to_member_id',
    convertedToMember: 'converted_to_member',
    convertedAt: 'converted_at'
};

// Table name mappings - Firebase uyumlu şema için artık gerekli değil!
const TABLE_MAPPINGS = {
    // preRegistrations: 'preRegistrations',  // Artık dönüşüm yok
    // Firebase ile aynı isimleri kullanıyoruz
};

function convertFieldNames(obj) {
    const converted = {};
    for (const [key, value] of Object.entries(obj)) {
        const newKey = FIELD_MAPPINGS[key] || key;
        
        // Convert nested objects and arrays
        if (value && typeof value === 'object' && !Array.isArray(value) && !(value instanceof Date)) {
            converted[newKey] = convertFieldNames(value);
        } else {
            converted[newKey] = value;
        }
    }
    return converted;
}

function getTableName(collectionName) {
    // Firebase uyumlu şema - tablo isimleri aynen kullanılıyor
    return collectionName; // TABLE_MAPPINGS[collectionName] || collectionName;
}

/**
 * Firebase verilerini Supabase/PostgreSQL uyumlu hale getirir
 */
function cleanData(obj) {
    if (!obj || typeof obj !== 'object') return obj;
    
    const cleaned = {};
    for (const [key, value] of Object.entries(obj)) {
        // Firebase timestamp objesini Date'e dönüştür
        if (value && typeof value === 'object' && value._seconds !== undefined) {
            cleaned[key] = new Date(value._seconds * 1000).toISOString();
        }
        // Boş string timestamp'leri null yap
        else if (value === '' && (key.toLowerCase().includes('date') || key.toLowerCase().includes('at') || key.toLowerCase().includes('time'))) {
            cleaned[key] = null;
        }
        // "default" string'ini false yap (boolean alanlar için)
        else if (value === 'default' && typeof value === 'string' && !key.toLowerCase().includes('permission')) {
            cleaned[key] = false;
        }
        // Nested objeler için recursive temizleme
        else if (value && typeof value === 'object' && !Array.isArray(value)) {
            cleaned[key] = cleanData(value);
        }
        // Array'ler için her elemanı temizle
        else if (Array.isArray(value)) {
            cleaned[key] = value.map(item => 
                typeof item === 'object' ? cleanData(item) : item
            );
        }
        // Diğer değerler aynen
        else {
            cleaned[key] = value;
        }
    }
    return cleaned;
}

async function importCollection(collectionName, data) {
    if (!data || data.length === 0) {
        console.log(`⏭️  Skipping ${collectionName} (no data)`);
        return { success: 0, errors: 0 };
    }
    
    console.log(`\n📥 Importing ${data.length} records to ${collectionName}...`);
    
    const tableName = getTableName(collectionName);
    let successCount = 0;
    let errorCount = 0;
    
    // Import in batches of 100
    const batchSize = 100;
    for (let i = 0; i < data.length; i += batchSize) {
        const batch = data.slice(i, i + batchSize);
        // Veri temizleme: Firebase timestamp, boş string, "default" vb.
        const cleanedBatch = batch.map(cleanData);
        
        try {
            const { data: result, error } = await supabase
                .from(tableName)
                .insert(cleanedBatch);
            
            if (error) {
                console.error(`❌ Batch error (${i}-${i + batch.length}):`, error.message);
                errorCount += batch.length;
            } else {
                successCount += batch.length;
                console.log(`✅ Imported batch ${i / batchSize + 1} (${batch.length} records)`);
            }
        } catch (error) {
            console.error(`❌ Exception in batch (${i}-${i + batch.length}):`, error.message);
            errorCount += batch.length;
        }
    }
    
    console.log(`✅ ${collectionName}: ${successCount} success, ${errorCount} errors`);
    return { success: successCount, errors: errorCount };
}

async function importCrmTags(crmTagsByClub) {
    if (!crmTagsByClub || Object.keys(crmTagsByClub).length === 0) {
        console.log(`⏭️  Skipping crmTags (no data)`);
        return { success: 0, errors: 0 };
    }
    
    console.log(`\n📥 Importing CRM Tags by club...`);
    
    let successCount = 0;
    let errorCount = 0;
    
    for (const [clubId, tags] of Object.entries(crmTagsByClub)) {
        const tagsWithClubId = tags.map(tag => ({
            ...tag,
            clubId: clubId  // Firebase field adı
        }));
        
        // Veri temizleme
        const cleanedTags = tagsWithClubId.map(cleanData);
        
        try {
            const { data, error } = await supabase
                .from('crmTags')  // Firebase uyumlu tablo adı
                .insert(cleanedTags);
            
            if (error) {
                console.error(`❌ Error importing tags for club ${clubId}:`, error.message);
                errorCount += tags.length;
            } else {
                successCount += tags.length;
                console.log(`✅ Imported ${tags.length} tags for club ${clubId}`);
            }
        } catch (error) {
            console.error(`❌ Exception importing tags for club ${clubId}:`, error.message);
            errorCount += tags.length;
        }
    }
    
    console.log(`✅ CRM Tags: ${successCount} success, ${errorCount} errors`);
    return { success: successCount, errors: errorCount };
}

async function main() {
    console.log('🚀 Supabase Data Import Started');
    console.log('================================\n');
    
    // Find the most recent export file
    const exportDir = path.join(__dirname, 'exports');
    if (!fs.existsSync(exportDir)) {
        console.error('❌ exports directory not found. Please run firebase-export.js first.');
        process.exit(1);
    }
    
    const files = fs.readdirSync(exportDir)
        .filter(f => f.startsWith('firebase-export-') && f.endsWith('.json'))
        .sort()
        .reverse();
    
    if (files.length === 0) {
        console.error('❌ No export files found. Please run firebase-export.js first.');
        process.exit(1);
    }
    
    const exportFile = path.join(exportDir, files[0]);
    console.log(`📂 Reading from: ${exportFile}\n`);
    
    const exportData = JSON.parse(fs.readFileSync(exportFile, 'utf8'));
    
    // Import order (respecting foreign key constraints)
    const importOrder = [
        'clubs',
        'settings',
        'users',
        'branches',
        'members',
        'preRegistrations',
        'groups',
        'schedules',
        'attendanceRecords',
        'crmLeads',
        // 'crmTags' will be handled separately
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
        'holidays'
    ];
    
    const results = {};
    
    // Import collections in order
    for (const collectionName of importOrder) {
        if (exportData.collections[collectionName]) {
            results[collectionName] = await importCollection(
                collectionName,
                exportData.collections[collectionName]
            );
        }
    }
    
    // ✅ Firebase'deki "attendance" collection'ını "attendanceRecords" tablosuna import et
    if (exportData.collections.attendance && exportData.collections.attendance.length > 0) {
        console.log('\n🔄 Firebase "attendance" collection\'ı "attendanceRecords" tablosuna aktarılıyor...');
        const attendanceResult = await importCollection('attendanceRecords', exportData.collections.attendance);
        
        // Eğer zaten attendanceRecords varsa sonuçları birleştir
        if (results.attendanceRecords) {
            results.attendanceRecords.success += attendanceResult.success;
            results.attendanceRecords.errors += attendanceResult.errors;
        } else {
            results.attendanceRecords = attendanceResult;
        }
        console.log(`✅ ${attendanceResult.success} attendance kaydı import edildi`);
    }
    
    // Import CRM tags (subcollection)
    if (exportData.collections.crmTagsByClub) {
        results.crmTags = await importCrmTags(exportData.collections.crmTagsByClub);
    }
    
    // Print summary
    console.log('\n================================');
    console.log('✅ Import completed!');
    console.log('\n📊 Summary:');
    
    let totalSuccess = 0;
    let totalErrors = 0;
    
    for (const [collection, result] of Object.entries(results)) {
        console.log(`   ${collection}: ${result.success} success, ${result.errors} errors`);
        totalSuccess += result.success;
        totalErrors += result.errors;
    }
    
    console.log(`\n📦 Total: ${totalSuccess} imported, ${totalErrors} errors`);
    
    if (totalErrors > 0) {
        console.log('\n⚠️  Some records failed to import. Check the logs above for details.');
    }
    
    process.exit(0);
}

// Run the import
main().catch(error => {
    console.error('❌ Fatal error:', error);
    process.exit(1);
});

