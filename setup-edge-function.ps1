# Edge Function Kurulum Script
# PowerShell ile çalıştırın: .\setup-edge-function.ps1

Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "🚀 SUPABASE EDGE FUNCTION KURULUM" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# 1. Supabase CLI kontrolü
Write-Host "📋 1. Supabase CLI kontrol ediliyor..." -ForegroundColor Yellow
$supabaseCli = Get-Command supabase -ErrorAction SilentlyContinue

if (-not $supabaseCli) {
    Write-Host "❌ Supabase CLI bulunamadı!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Kurulum için:" -ForegroundColor Yellow
    Write-Host "  1. Scoop ile: scoop install supabase" -ForegroundColor White
    Write-Host "  2. Manuel: https://github.com/supabase/cli/releases" -ForegroundColor White
    Write-Host ""
    exit 1
}

Write-Host "✅ Supabase CLI bulundu: $(supabase --version)" -ForegroundColor Green
Write-Host ""

# 2. Giriş kontrolü
Write-Host "📋 2. Supabase girişi kontrol ediliyor..." -ForegroundColor Yellow
$loginCheck = supabase projects list 2>&1

if ($loginCheck -match "not logged in") {
    Write-Host "⚠️  Supabase'e giriş yapmanız gerekiyor!" -ForegroundColor Red
    Write-Host ""
    $login = Read-Host "Şimdi giriş yapmak ister misiniz? (E/H)"
    
    if ($login -eq "E" -or $login -eq "e") {
        supabase login
    } else {
        Write-Host "❌ Giriş yapılmadan devam edilemiyor!" -ForegroundColor Red
        exit 1
    }
}

Write-Host "✅ Supabase'e giriş yapılmış" -ForegroundColor Green
Write-Host ""

# 3. Project ID al
Write-Host "📋 3. Proje bağlantısı..." -ForegroundColor Yellow
Write-Host "Supabase Dashboard'dan Project ID'nizi alın:" -ForegroundColor White
Write-Host "   Dashboard > Project Settings > General > Reference ID" -ForegroundColor Gray
Write-Host ""

$projectId = Read-Host "Project ID girin"

if ([string]::IsNullOrWhiteSpace($projectId)) {
    Write-Host "❌ Project ID gerekli!" -ForegroundColor Red
    exit 1
}

Write-Host "🔗 Proje bağlanıyor..." -ForegroundColor Yellow
supabase link --project-ref $projectId

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Proje bağlantısı başarısız!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Proje bağlandı" -ForegroundColor Green
Write-Host ""

# 4. autoReplySent tablosu oluştur
Write-Host "📋 4. Veritabanı tablosu oluşturuluyor..." -ForegroundColor Yellow
Write-Host "Supabase Dashboard > SQL Editor'de aşağıdaki dosyayı çalıştırın:" -ForegroundColor White
Write-Host "   create-autoReplySent-table.sql" -ForegroundColor Cyan
Write-Host ""
$dbReady = Read-Host "Tablo oluşturuldu mu? (E/H)"

if ($dbReady -ne "E" -and $dbReady -ne "e") {
    Write-Host "❌ Veritabanı hazır değil, kurulum iptal edildi!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Veritabanı tablosu hazır" -ForegroundColor Green
Write-Host ""

# 5. Edge Function deploy
Write-Host "📋 5. Edge Function deploy ediliyor..." -ForegroundColor Yellow
supabase functions deploy auto-reply-missed-calls

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Deploy başarısız!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Edge Function deploy edildi" -ForegroundColor Green
Write-Host ""

# 6. Cron Job kurulumu talimatları
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "📋 6. CRON JOB KURULUMU (SON ADIM!)" -ForegroundColor Yellow
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Supabase Dashboard'da şu adımları izleyin:" -ForegroundColor White
Write-Host ""
Write-Host "1. Database > Extensions > pg_cron'u enable edin" -ForegroundColor Cyan
Write-Host "2. SQL Editor'de şu komutu çalıştırın:" -ForegroundColor Cyan
Write-Host ""

$cronSql = @"
SELECT cron.schedule(
  'auto-reply-missed-calls',
  '*/2 * * * *',
  `$`$
  SELECT
    net.http_post(
      url:='https://$projectId.supabase.co/functions/v1/auto-reply-missed-calls',
      headers:='{"Content-Type": "application/json", "Authorization": "Bearer YOUR_ANON_KEY"}'::jsonb,
      body:='{}'::jsonb
    ) as request_id;
  `$`$
);
"@

Write-Host $cronSql -ForegroundColor Yellow
Write-Host ""
Write-Host "⚠️  YOUR_ANON_KEY yerine:" -ForegroundColor Red
Write-Host "   Project Settings > API > anon public key" -ForegroundColor White
Write-Host ""

# 7. Test
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "🧪 MANUEL TEST" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Test için:" -ForegroundColor White
Write-Host '  curl -X POST "https://' + $projectId + '.supabase.co/functions/v1/auto-reply-missed-calls" \' -ForegroundColor Yellow
Write-Host '    -H "Authorization: Bearer YOUR_ANON_KEY" \' -ForegroundColor Yellow
Write-Host '    -H "Content-Type: application/json"' -ForegroundColor Yellow
Write-Host ""

Write-Host "Log kontrolü:" -ForegroundColor White
Write-Host "  supabase functions logs auto-reply-missed-calls --tail" -ForegroundColor Yellow
Write-Host ""

Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "✅ KURULUM TAMAMLANDI!" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Sistem artık her 2 dakikada bir otomatik çalışacak!" -ForegroundColor Green
Write-Host "Sayfa kapalı olsa bile mesajlar gönderilecek." -ForegroundColor Green
Write-Host ""
