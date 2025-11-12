# Otomatik Zamanlanmış Yedekleme Scripti
# Windows Task Scheduler ile çalıştırılmak üzere tasarlanmıştır

# Tam yol belirtmeliyiz
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$backupScriptPath = Join-Path $scriptPath "backup.ps1"

# Log dosyası
$logPath = Join-Path $scriptPath "scheduled-backup-log.txt"

# Log başlangıcı
$startTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$logEntry = @"

===========================================
Zamanlanmış Yedekleme Başladı: $startTime
===========================================

"@
Add-Content -Path $logPath -Value $logEntry

try {
    # Backup scriptini çalıştır
    Set-Location $scriptPath
    
    & $backupScriptPath -message "Zamanlanmış otomatik yedekleme - $startTime" -createBackupBranch:$false
    
    $endTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $successLog = @"
✅ Yedekleme başarılı: $endTime

"@
    Add-Content -Path $logPath -Value $successLog
    
} catch {
    $endTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $errorLog = @"
❌ HATA OLUŞTU: $endTime
Hata Detayı: $_

"@
    Add-Content -Path $logPath -Value $errorLog
}
