# Git Yedekleme Geri Dönüş Scripti
# Önceki yedeğe geri dönmek için kullanın

param(
    [switch]$listBackups = $false,
    [string]$backupTag = "",
    [switch]$help = $false
)

function Write-Info { param($text) Write-Host "ℹ️  $text" -ForegroundColor Cyan }
function Write-Success { param($text) Write-Host "✅ $text" -ForegroundColor Green }
function Write-Warning { param($text) Write-Host "⚠️  $text" -ForegroundColor Yellow }
function Write-Error-Custom { param($text) Write-Host "❌ $text" -ForegroundColor Red }

if ($help) {
    Write-Host @"

🔄 Git Yedekleme Geri Dönüş Scripti
===================================

KULLANIM:
    .\restore.ps1 -listBackups              # Tüm yedeklemeleri listele
    .\restore.ps1 -backupTag "tag-adı"      # Belirtilen yedeklemeye dön
    .\restore.ps1 -help                     # Bu yardım mesajını göster

ÖRNEKLER:
    .\restore.ps1 -listBackups
    .\restore.ps1 -backupTag "yedek-2024-01-15_10-30-00"

NOT: Geri dönüş işlemi mevcut değişikliklerinizi etkileyebilir!
     İşlem öncesi mevcut çalışmanızı yedeklemeniz önerilir.

"@ -ForegroundColor White
    exit 0
}

# Yedeklemeleri listele
if ($listBackups) {
    Write-Info "Mevcut yedeklemeler getiriliyor..."
    
    # Önce remote tag'leri çek
    git fetch --tags 2>&1 | Out-Null
    
    Write-Host "`n📋 Mevcut Yedeklemeler:`n" -ForegroundColor Yellow
    
    # Yedek tag'lerini listele
    $tags = git tag -l "yedek-*" | Sort-Object -Descending
    
    if ($tags.Count -eq 0) {
        Write-Warning "Henüz yedekleme bulunmuyor."
        Write-Info "Yedekleme oluşturmak için: .\backup.ps1"
        exit 0
    }
    
    $counter = 1
    foreach ($tag in $tags) {
        # Tag detaylarını al
        $tagDate = $tag -replace "yedek-", "" -replace "_", " " -replace "-", ":"
        $tagInfo = git show $tag --format="%ci %s" --quiet 2>&1
        
        Write-Host "$counter. " -NoNewline -ForegroundColor White
        Write-Host "$tag" -ForegroundColor Green
        Write-Host "   📅 Tarih: $tagDate" -ForegroundColor Gray
        
        $counter++
    }
    
    Write-Host "`n💡 Geri dönmek için:" -ForegroundColor Cyan
    Write-Host "   .\restore.ps1 -backupTag `"tag-adı`"`n" -ForegroundColor White
    
    # Backup branch'leri de göster
    Write-Info "Yedek branch'ler kontrol ediliyor..."
    $backupBranches = git branch -a | Select-String "backup/"
    
    if ($backupBranches) {
        Write-Host "`n🌿 Yedek Branch'ler:`n" -ForegroundColor Yellow
        foreach ($branch in $backupBranches) {
            Write-Host "   $branch" -ForegroundColor Green
        }
    }
    
    exit 0
}

# Geri dönüş işlemi
if ([string]::IsNullOrWhiteSpace($backupTag)) {
    Write-Error-Custom "Yedekleme tag'i belirtilmedi!"
    Write-Info "Kullanım: .\restore.ps1 -backupTag `"tag-adı`""
    Write-Info "Mevcut yedeklemeleri görmek için: .\restore.ps1 -listBackups"
    exit 1
}

Write-Warning "`n⚠️  DİKKAT: Geri dönüş işlemi başlıyor!"
Write-Host "   Yedekleme: $backupTag" -ForegroundColor White

# Kullanıcıdan onay al
Write-Host "`nMevcut değişiklikleri kaybolabilir!" -ForegroundColor Red
$confirmation = Read-Host "Devam etmek istiyor musunuz? (E/H)"

if ($confirmation -ne "E" -and $confirmation -ne "e") {
    Write-Info "İşlem iptal edildi."
    exit 0
}

# Önce fetch yap
Write-Info "Uzak repository'den güncellemeler çekiliyor..."
git fetch --all --tags 2>&1 | Out-Null

# Tag'in var olup olmadığını kontrol et
$tagExists = git tag -l $backupTag

if ([string]::IsNullOrWhiteSpace($tagExists)) {
    Write-Error-Custom "Tag bulunamadı: $backupTag"
    Write-Info "Mevcut tag'leri görmek için: .\restore.ps1 -listBackups"
    exit 1
}

# Mevcut değişiklikleri kaydet (güvenlik için)
$currentTime = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$safeBranch = "onceki-durum-$currentTime"

Write-Info "Güvenlik için mevcut durum kaydediliyor..."
git stash push -u -m "Geri dönüş öncesi otomatik kayıt - $currentTime"

# Yeni bir güvenlik branch'i oluştur
$currentBranch = git rev-parse --abbrev-ref HEAD
git branch $safeBranch 2>&1 | Out-Null
Write-Success "Güvenlik branch'i oluşturuldu: $safeBranch"

# Geri dönüş yap
Write-Info "Yedeğe geri dönülüyor: $backupTag"
git checkout $backupTag

if ($LASTEXITCODE -ne 0) {
    Write-Error-Custom "Geri dönüş başarısız!"
    git checkout $currentBranch
    exit 1
}

# Yeni bir branch oluştur
$restoreBranch = "restore-$currentTime"
git checkout -b $restoreBranch

Write-Success "`n==================================="
Write-Success "Geri Dönüş Başarılı!"
Write-Success "==================================="
Write-Host "`n📦 Yeni Branch: $restoreBranch" -ForegroundColor White
Write-Host "🔄 Geri Dönülen Yedek: $backupTag" -ForegroundColor White
Write-Host "💾 Önceki Durum: $safeBranch (branch)" -ForegroundColor White
Write-Host "`n💡 Ana branch'e dönmek için:" -ForegroundColor Cyan
Write-Host "   git checkout $currentBranch`n" -ForegroundColor White
Write-Host "💡 Bu durumu kalıcı hale getirmek için:" -ForegroundColor Cyan
Write-Host "   git checkout $currentBranch" -ForegroundColor White
Write-Host "   git reset --hard $backupTag`n" -ForegroundColor White
