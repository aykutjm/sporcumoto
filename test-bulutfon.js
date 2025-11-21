// Bulutfon API Test
require('dotenv').config();

const BULUTFON_API_KEY = 'qEtv33s3Ys6E5Rf_lknNuisaWn2X65DP_zCgIiKllzASeqmzNATVwxHB6-t-HOsmSho';
const BULUTFON_API_URL = 'https://api.bulutfon.com';

async function testBulutfonAPI() {
  const today = new Date().toISOString().split('T')[0];
  
  console.log('🔍 Bulutfon API Test');
  console.log('📅 Tarih:', today);
  console.log('🔑 API Key:', BULUTFON_API_KEY.substring(0, 20) + '...');
  console.log('🌐 URL:', `${BULUTFON_API_URL}/dids/${today}`);
  
  try {
    const response = await fetch(`${BULUTFON_API_URL}/dids/${today}`, {
      headers: {
        'Authorization': `Bearer ${BULUTFON_API_KEY}`,
        'Content-Type': 'application/json'
      }
    });
    
    console.log('\n📊 Response Status:', response.status);
    console.log('📊 Response Status Text:', response.statusText);
    
    const data = await response.json();
    console.log('\n📦 Response Data:', JSON.stringify(data, null, 2));
    
  } catch (error) {
    console.error('❌ Hata:', error.message);
  }
}

testBulutfonAPI();
