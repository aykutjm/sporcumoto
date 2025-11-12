# Otomatik Git Commit ve Push
# Kullanım: .\auto-commit.ps1 "Commit mesajınız"

param(
    [string]$message = "Auto-commit: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
)

Write-Host "🔍 Git durumu kontrol ediliyor..." -ForegroundColor Cyan

# Git durumunu kontrol et
$status = git status --porcelain

if ([string]::IsNullOrWhiteSpace($status)) {
    Write-Host "✅ Değişiklik yok, commit gerekmiyor." -ForegroundColor Green
    exit 0
}

Write-Host "📝 Değişiklikler bulundu:" -ForegroundColor Yellow
git status --short

Write-Host "`n➕ Dosyalar stage'e ekleniyor..." -ForegroundColor Cyan
git add .

Write-Host "💾 Commit yapılıyor..." -ForegroundColor Cyan
git commit -m $message

Write-Host "🚀 GitHub'a push ediliyor..." -ForegroundColor Cyan
git push origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ Başarıyla GitHub'a yüklendi!" -ForegroundColor Green
} else {
    Write-Host "`n❌ Hata oluştu!" -ForegroundColor Red
}
