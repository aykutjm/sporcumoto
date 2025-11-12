# Gelişmiş Otomatik Git Yedekleme
# Her yedekleme tarih-saat damgalı olarak saklanır
# İstediğiniz zaman geri dönüş yapabilirsiniz

param(
    [string]$message = "",
    [switch]$createBackupBranch = $false
)

# Renkli çıktı için fonksiyonlar
function Write-Info { param($text) Write-Host "[INFO] $text" -ForegroundColor Cyan }
function Write-Success { param($text) Write-Host "[OK] $text" -ForegroundColor Green }
function Write-Warning { param($text) Write-Host "[UYARI] $text" -ForegroundColor Yellow }
function Write-Error-Custom { param($text) Write-Host "[HATA] $text" -ForegroundColor Red }

# Tarih damgası oluştur
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$dateForMessage = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Write-Info "Git durumu kontrol ediliyor..."

# Git durumunu kontrol et
$status = git status --porcelain 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Error-Custom "Bu klasör bir Git repository değil!"
    Write-Info "Yeni bir Git repository başlatmak için: git init"
    exit 1
}

if ([string]::IsNullOrWhiteSpace($status)) {
    Write-Success "Degisiklik yok, yedekleme gerekmiyor."
    exit 0
}

Write-Warning "Degisiklikler bulundu:"
git status --short

# Commit mesajini olustur
if ([string]::IsNullOrWhiteSpace($message)) {
    $message = "Otomatik Yedekleme - $dateForMessage"
}

# Backup branch olustur (istege bagli)
if ($createBackupBranch) {
    $currentBranch = git rev-parse --abbrev-ref HEAD
    $backupBranchName = "backup/$timestamp"
    
    Write-Info "Yedek branch olusturuluyor: $backupBranchName"
    git branch $backupBranchName
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Yedek branch olusturuldu: $backupBranchName"
    }
}

# Dosyalari stage'e ekle
Write-Info "Dosyalar stage'e ekleniyor..."
git add -A

# Commit yap
Write-Info "Commit yapiliyor..."
git commit -m $message

if ($LASTEXITCODE -ne 0) {
    Write-Error-Custom "Commit islemi basarisiz!"
    exit 1
}

# Son commit hash'ini al
$commitHash = git rev-parse --short HEAD
Write-Success "Commit olusturuldu: $commitHash"

# Tag ekle (kolay geri donus icin)
$tagName = "yedek-$timestamp"
Write-Info "Yedekleme tag'i ekleniyor: $tagName"
git tag -a $tagName -m "Otomatik yedekleme - $dateForMessage"

# Push yap
Write-Info "GitHub'a gonderiliyor..."

# Ana branch'i push et
$currentBranch = git rev-parse --abbrev-ref HEAD
git push origin $currentBranch

if ($LASTEXITCODE -ne 0) {
    Write-Warning "Push islemi basarisiz! Internet baglantinizi kontrol edin."
    Write-Info "Yerel yedekleme tamamlandi, ancak GitHub'a gonderilemedi."
    exit 1
}

# Tag'leri push et
Write-Info "Tag'ler gonderiliyor..."
git push origin $tagName

if ($createBackupBranch) {
    Write-Info "Yedek branch'i gonderiliyor..."
    git push origin $backupBranchName
}

Write-Success "`n==================================="
Write-Success "Yedekleme Basariyla Tamamlandi!"
Write-Success "==================================="
Write-Host "`nCommit Hash: $commitHash" -ForegroundColor White
Write-Host "Tag: $tagName" -ForegroundColor White
if ($createBackupBranch) {
    Write-Host "Backup Branch: $backupBranchName" -ForegroundColor White
}
Write-Host "Tarih: $dateForMessage`n" -ForegroundColor White

# Yedekleme logunu kaydet
$logFile = "backup-log.txt"
$logEntry = @"
=================================
Yedekleme: $dateForMessage
Commit: $commitHash
Tag: $tagName
Mesaj: $message
=================================

"@
Add-Content -Path $logFile -Value $logEntry

Write-Info "Yedekleme kaydi 'backup-log.txt' dosyasina yazildi."
