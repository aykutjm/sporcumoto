# Hızlı Kurulum Script - Auto Reply
# PowerShell ile çalıştırın

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "🚀 AUTO REPLY MISSED CALLS - KURULUM" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# 1. Node.js kontrolü
Write-Host "📋 1. Node.js kontrol ediliyor..." -ForegroundColor Yellow
$nodeVersion = node --version 2>$null
if (-not $nodeVersion) {
    Write-Host "❌ Node.js bulunamadı! Lütfen Node.js kurun: https://nodejs.org" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Node.js bulundu: $nodeVersion" -ForegroundColor Green
Write-Host ""

# 2. NPM paketlerini kur
Write-Host "📋 2. NPM paketleri kuruluyor..." -ForegroundColor Yellow
npm install @supabase/supabase-js node-fetch dotenv
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Paket kurulumu başarısız!" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Paketler kuruldu" -ForegroundColor Green
Write-Host ""

# 3. .env dosyası oluştur
Write-Host "📋 3. .env dosyası kontrol ediliyor..." -ForegroundColor Yellow
if (-not (Test-Path ".env")) {
    if (Test-Path ".env.example") {
        Copy-Item ".env.example" ".env"
        Write-Host "✅ .env dosyası oluşturuldu (.env.example'dan)" -ForegroundColor Green
        Write-Host ""
        Write-Host "⚠️  ÖNEMLİ: .env dosyasını düzenleyin!" -ForegroundColor Yellow
        Write-Host "   - Supabase Dashboard > Settings > API" -ForegroundColor White
        Write-Host "   - SUPABASE_URL ve SUPABASE_SERVICE_ROLE_KEY değerlerini girin" -ForegroundColor White
        Write-Host ""
        
        $editNow = Read-Host ".env dosyasını şimdi düzenlemek ister misiniz? (E/H)"
        if ($editNow -eq "E" -or $editNow -eq "e") {
            notepad .env
        }
    } else {
        Write-Host "❌ .env.example dosyası bulunamadı!" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✅ .env dosyası mevcut" -ForegroundColor Green
}
Write-Host ""

# 4. Supabase tablosu kontrolü
Write-Host "📋 4. Veritabanı tablosu..." -ForegroundColor Yellow
Write-Host "   Supabase Dashboard > SQL Editor'de şu dosyayı çalıştırın:" -ForegroundColor White
Write-Host "   create-autoReplySent-table-CLEAN.sql" -ForegroundColor Cyan
Write-Host ""
$dbReady = Read-Host "Tablo oluşturuldu mu? (E/H)"
if ($dbReady -ne "E" -and $dbReady -ne "e") {
    Write-Host "❌ Veritabanı hazır değil, kurulum iptal edildi!" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Veritabanı tablosu hazır" -ForegroundColor Green
Write-Host ""

# 5. Test
Write-Host "5. Script test ediliyor..." -ForegroundColor Yellow
node auto-reply-missed-calls.js
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Test başarısız! Log'ları kontrol edin." -ForegroundColor Red
    exit 1
}
Write-Host ""

# 6. Task Scheduler kurulum seçeneği
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "📋 6. OTOMATİK ÇALIŞTIRMA (İSTEĞE BAĞLI)" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Script her 2 dakikada bir otomatik çalışsın mı?" -ForegroundColor White
$autoRun = Read-Host "(E) Task Scheduler, (P) PM2, (H) Hayır"

if ($autoRun -eq "E" -or $autoRun -eq "e") {
    Write-Host ""
    Write-Host "Task Scheduler açılıyor..." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Manuel Adımlar:" -ForegroundColor White
    Write-Host "1. Create Basic Task tıklayın" -ForegroundColor Gray
    Write-Host "2. Name: Auto Reply Missed Calls" -ForegroundColor Gray
    Write-Host "3. Trigger: Daily" -ForegroundColor Gray
    Write-Host "4. Action: Start a program" -ForegroundColor Gray
    Write-Host "5. Program: $(Get-Location)\run-auto-reply.bat" -ForegroundColor Cyan
    Write-Host "6. Properties - Triggers - Repeat every: 2 minutes" -ForegroundColor Gray
    Write-Host ""
    
    taskschd.msc
    
} elseif ($autoRun -eq "P" -or $autoRun -eq "p") {
    Write-Host ""
    Write-Host "PM2 kuruluyor..." -ForegroundColor Yellow
    npm install -g pm2
    
    Write-Host "PM2 ile başlatılıyor..." -ForegroundColor Yellow
    pm2 start auto-reply-missed-calls.js --cron "*/2 * * * *" --name "auto-reply"
    pm2 save
    
    Write-Host "✅ PM2 ile kuruldu!" -ForegroundColor Green
    Write-Host ""
    Write-Host "PM2 Komutları:" -ForegroundColor White
    Write-Host "  pm2 status              # Durum" -ForegroundColor Gray
    Write-Host "  pm2 logs auto-reply     # Log" -ForegroundColor Gray
    Write-Host "  pm2 restart auto-reply  # Yeniden başlat" -ForegroundColor Gray
    Write-Host ""
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "✅ KURULUM TAMAMLANDI!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Test için:" -ForegroundColor White
Write-Host "  node auto-reply-missed-calls.js" -ForegroundColor Cyan
Write-Host ""
Write-Host "Log kontrolü:" -ForegroundColor White
Write-Host "  Get-Content auto-reply.log -Tail 20 -Wait" -ForegroundColor Cyan
Write-Host ""
