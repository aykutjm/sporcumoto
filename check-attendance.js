// Check latest attendance records from Supabase
const { createClient } = require('@supabase/supabase-js');

const SUPABASE_URL = 'https://supabase.edu-ai.online';
const SUPABASE_ANON_KEY = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzdXBhYmFzZSIsImlhdCI6MTc2MjEwNTMyMCwiZXhwIjo0OTE3Nzc4OTIwLCJyb2xlIjoiYW5vbiJ9.HXUza0GT82-trWkx0WWKe-nY7KsGrIjIHSOJPKsOHjs';
const CLUB_ID = 'FmvoFvTCek44CR3pS4XC';

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

async function checkAttendance() {
    console.log('📊 Checking attendance records from Supabase...\n');
    
    // Get all absent records sorted by date
    const { data, error } = await supabase
        .from('attendanceRecords')
        .select('*')
        .eq('clubId', CLUB_ID)
        .eq('status', 'absent')
        .order('date', { ascending: false })
        .limit(20);
    
    if (error) {
        console.error('❌ Error:', error);
        return;
    }
    
    console.log(`✅ Found ${data.length} recent absence records:\n`);
    
    data.forEach((record, index) => {
        console.log(`${index + 1}. Date: ${record.date}`);
        console.log(`   Member ID: ${record.memberId}`);
        console.log(`   Reason: ${record.reason || 'Not specified'}`);
        console.log(`   Recorded by: ${record.recordedBy}`);
        console.log('');
    });
    
    // Also check total count
    const { count, error: countError } = await supabase
        .from('attendanceRecords')
        .select('*', { count: 'exact', head: true })
        .eq('clubId', CLUB_ID)
        .eq('status', 'absent');
    
    if (!countError) {
        console.log(`\n📈 Total absent records in database: ${count}`);
    }
}

checkAttendance().catch(console.error);
