// Service Role Key'i Admin Console'dan Al
// Tarayıcı Console'da (F12) çalıştırın

// 1. Supabase client'tan key bilgisini al
console.log('=== SUPABASE CONFIGURATION ===');
console.log('URL:', supabase.supabaseUrl);
console.log('Anon Key:', supabase.supabaseKey);

// 2. Service Role Key'i manuel olarak oluşturma
// JWT formatı: eyJ... ile başlar
console.log('\n⚠️ Service Role Key admin panelinden manuel alınmalı');
console.log('📍 Supabase Dashboard > Settings > API > service_role key');

// 3. Alternatif: Project API'den key bilgilerini çek
fetch('https://supabase.edu-ai.online/api/props', {
  credentials: 'include'
})
.then(r => r.json())
.then(data => {
  console.log('\n=== PROJECT DATA ===');
  console.log(data);
})
.catch(e => console.error('API çağrısı başarısız:', e));
