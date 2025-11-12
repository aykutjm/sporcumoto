# 🔄 Git Otomatik Yedekleme Sistemi

Bu klasörde GitHub için gelişmiş bir otomatik yedekleme sistemi bulunmaktadır. Her yedekleme tarih-saat damgalı olarak kaydedilir ve istediğiniz zaman önceki bir versiyona dönebilirsiniz.

## 📋 İçindekiler

- [Hızlı Başlangıç](#hızlı-başlangıç)
- [Manuel Yedekleme](#manuel-yedekleme)
- [Otomatik Yedekleme](#otomatik-yedekleme)
- [Geri Dönüş](#geri-dönüş)
- [Özellikler](#özellikler)

---

## 🚀 Hızlı Başlangıç

### 1️⃣ İlk Kurulum

Eğer henüz Git repository'niz yoksa:

```powershell
# Git repository başlat
git init

# GitHub'da yeni bir repo oluşturun ve bağlayın
git remote add origin https://github.com/kullaniciadi/repo-adi.git

# İlk commit
git add .
git commit -m "İlk commit"
git branch -M main
git push -u origin main
```

### 2️⃣ İlk Yedeğinizi Oluşturun

```powershell
.\backup.ps1
```

---

## 💾 Manuel Yedekleme

### Basit Yedekleme

```powershell
# Otomatik mesajla yedekleme
.\backup.ps1

# Özel mesajla yedekleme
.\backup.ps1 -message "Önemli değişiklikler yapıldı"
```

### Yedek Branch ile Yedekleme

Önemli değişiklikler öncesi ayrı bir branch de oluşturabilirsiniz:

```powershell
.\backup.ps1 -message "Kritik güncelleme öncesi" -createBackupBranch
```

Bu şunları yapar:
- ✅ Normal commit oluşturur
- ✅ Tarih-saat damgalı tag ekler (örn: `yedek-2024-01-15_10-30-00`)
- ✅ Ayrı bir yedek branch oluşturur (örn: `backup/2024-01-15_10-30-00`)
- ✅ Her şeyi GitHub'a yükler

---

## ⏰ Otomatik Yedekleme

### Windows Task Scheduler ile Kurulum

#### Yöntem 1: Grafik Arayüz

1. **Task Scheduler'ı açın:**
   - Windows tuşuna basın
   - "Task Scheduler" yazın ve açın

2. **Yeni görev oluşturun:**
   - Sağ tarafta "Create Basic Task" tıklayın
   - İsim: "Git Otomatik Yedekleme"
   - Açıklama: "Projeyi otomatik olarak yedekler"

3. **Tetikleyici (Trigger) ayarlayın:**
   - **Her saat:** Daily → Repeat task every: 1 hour
   - **Her gün:** Daily → Belirli bir saat seçin
   - **Haftada bir:** Weekly → Gün ve saat seçin

4. **Eylem (Action) ayarlayın:**
   - Action: Start a program
   - Program/script: `powershell.exe`
   - Add arguments: `-ExecutionPolicy Bypass -File "C:\Users\adnan\Desktop\Projeler\sporcum-supabase\scheduled-backup.ps1"`
   - Start in: `C:\Users\adnan\Desktop\Projeler\sporcum-supabase`

#### Yöntem 2: PowerShell ile Hızlı Kurulum

```powershell
# Saatlik yedekleme için
$action = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument "-ExecutionPolicy Bypass -File `"$PWD\scheduled-backup.ps1`"" `
    -WorkingDirectory $PWD

$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Hours 1)

Register-ScheduledTask -TaskName "Git Otomatik Yedekleme" `
    -Action $action -Trigger $trigger `
    -Description "Projeyi her saat yedekler"
```

### Otomatik Yedeklemeyi Test Etme

```powershell
# Zamanlanmış görevi manuel çalıştır
.\scheduled-backup.ps1

# Log dosyasını kontrol et
Get-Content scheduled-backup-log.txt -Tail 20
```

---

## 🔄 Geri Dönüş

### Mevcut Yedeklemeleri Görüntüleme

```powershell
.\restore.ps1 -listBackups
```

**Çıktı örneği:**
```
📋 Mevcut Yedeklemeler:

1. yedek-2024-01-15_14-30-00
   📅 Tarih: 2024-01-15 14:30:00

2. yedek-2024-01-15_10-00-00
   📅 Tarih: 2024-01-15 10:00:00

3. yedek-2024-01-14_16-45-00
   📅 Tarih: 2024-01-14 16:45:00
```

### Önceki Versiyona Dönme

```powershell
# Belirli bir yedeğe dön
.\restore.ps1 -backupTag "yedek-2024-01-15_10-00-00"
```

**Ne olur:**
1. ✅ Mevcut durumunuz güvenli bir branch'e kaydedilir
2. ✅ Seçtiğiniz yedeğe dönülür
3. ✅ Yeni bir restore branch'i oluşturulur
4. ✅ Hiçbir veri kaybolmaz!

### Geri Dönüşü Kalıcı Yapma

Eğer geri dönüş yaptığınız versiyonu kalıcı hale getirmek istiyorsanız:

```powershell
# Ana branch'e dön
git checkout main

# Seçtiğiniz yedeğe sıfırla
git reset --hard yedek-2024-01-15_10-00-00

# GitHub'a zorla push et (DİKKAT!)
git push origin main --force
```

⚠️ **DİKKAT:** `--force` kullanımı tehlikelidir! Emin değilseniz kullanmayın.

---

## ✨ Özellikler

### backup.ps1

- ✅ **Otomatik tarih-saat damgası:** Her yedekleme benzersiz bir zaman damgası alır
- ✅ **Git tag'leri:** Kolay geri dönüş için her yedeklemeye tag eklenir
- ✅ **Yedek branch'ler:** İsteğe bağlı branch oluşturma
- ✅ **Detaylı loglar:** Her yedekleme `backup-log.txt` dosyasına kaydedilir
- ✅ **Renkli çıktı:** Kolay takip için renkli terminal çıktısı
- ✅ **Hata kontrolü:** Internet bağlantısı ve Git hataları kontrol edilir

### scheduled-backup.ps1

- ✅ **Task Scheduler uyumlu:** Windows zamanlanmış görevler ile çalışır
- ✅ **Ayrı log dosyası:** `scheduled-backup-log.txt` ile izleme
- ✅ **Hata yakalama:** Hataları loglar ve devam eder

### restore.ps1

- ✅ **Güvenli geri dönüş:** Mevcut durum otomatik kaydedilir
- ✅ **Yedekleme listesi:** Tüm mevcut yedeklemeleri gösterir
- ✅ **Onay mekanizması:** Yanlışlıkla geri dönüşü engeller
- ✅ **Yeni branch oluşturma:** Geri dönüş sonrası yeni bir branch'te çalışırsınız

---

## 📊 Kullanım Örnekleri

### Senaryo 1: Günlük Çalışma

```powershell
# Sabah işe başlarken
.\backup.ps1 -message "İşe başlangıç - sabah yedeği"

# Öğle arası
.\backup.ps1 -message "Öğle arası yedeği"

# İş bitiminde
.\backup.ps1 -message "Gün sonu yedeği"
```

### Senaryo 2: Önemli Değişiklik Öncesi

```powershell
# Büyük bir refactor öncesi
.\backup.ps1 -message "Refactor öncesi güvenli yedek" -createBackupBranch

# Değişiklikleri yap...

# Test et...

# Sorun varsa geri dön
.\restore.ps1 -listBackups
.\restore.ps1 -backupTag "yedek-2024-01-15_10-00-00"
```

### Senaryo 3: Otomatik Yedekleme Takibi

```powershell
# Son 10 yedeği görüntüle
Get-Content backup-log.txt -Tail 50

# Zamanlanmış yedeklemeleri kontrol et
Get-Content scheduled-backup-log.txt -Tail 50
```

---

## 🔧 İleri Düzey Kullanım

### Tüm Yedekleme Geçmişini GitHub'dan Çekme

```powershell
# Tüm tag'leri çek
git fetch --all --tags

# Tüm branch'leri çek
git fetch --all

# Yedekleme listesini göster
.\restore.ps1 -listBackups
```

### Eski Yedekleri Temizleme

```powershell
# 30 günden eski tag'leri listele
git tag -l "yedek-*" | ForEach-Object {
    $tagDate = git log -1 --format=%ai $_
    if ((Get-Date $tagDate) -lt (Get-Date).AddDays(-30)) {
        Write-Host "Eski tag: $_" -ForegroundColor Yellow
    }
}

# Silmek için (DİKKAT!)
# git tag -d "yedek-2024-01-01_10-00-00"
# git push origin :refs/tags/yedek-2024-01-01_10-00-00
```

### Farklı Makineler Arası Senkronizasyon

```powershell
# Makine 1'de
.\backup.ps1 -message "Makine 1'den yedek"

# Makine 2'de
git fetch --all --tags
git pull origin main

# Makine 2'de çalışma devam eder...
.\backup.ps1 -message "Makine 2'den devam"
```

---

## 🆘 Sorun Giderme

### "execution of scripts is disabled" Hatası

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Push Hatası Alıyorum

```powershell
# Remote repository'yi kontrol et
git remote -v

# Doğru değilse düzelt
git remote set-url origin https://github.com/kullaniciadi/repo-adi.git

# Kimlik doğrulama gerekiyorsa
git config --global credential.helper wincred
```

### Tag'ler Görünmüyor

```powershell
# Remote tag'leri çek
git fetch --tags

# Tüm tag'leri göster
git tag -l
```

---

## 📝 Notlar

- 📌 Her yedekleme benzersiz bir `yedek-YYYY-MM-DD_HH-mm-ss` formatında tag alır
- 📌 `backup-log.txt` ve `scheduled-backup-log.txt` dosyaları .gitignore'a eklenebilir
- 📌 Büyük dosyalar için Git LFS kullanımı önerilir
- 📌 Gizli bilgiler içeren dosyalar için `.gitignore` kullanmayı unutmayın

---

## 🎯 Hızlı Komut Referansı

```powershell
# Yedekleme
.\backup.ps1                                    # Basit yedek
.\backup.ps1 -message "Mesaj"                   # Mesajlı yedek
.\backup.ps1 -createBackupBranch                # Branch ile yedek

# Geri dönüş
.\restore.ps1 -listBackups                      # Yedekleri listele
.\restore.ps1 -backupTag "tag-adı"              # Geri dön
.\restore.ps1 -help                             # Yardım

# Otomatik yedekleme
.\scheduled-backup.ps1                          # Manuel test
Get-Content scheduled-backup-log.txt            # Logları görüntüle

# Loglar
Get-Content backup-log.txt -Tail 20             # Son yedekler
Get-Content scheduled-backup-log.txt -Tail 20   # Zamanlanmış log
```

---

## 📞 Destek

Sorun yaşarsanız:
1. Log dosyalarını kontrol edin
2. Git durumunu kontrol edin: `git status`
3. Remote bağlantıyı kontrol edin: `git remote -v`

---

**Başarılar! 🚀**
