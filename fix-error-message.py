# WhatsApp 403 Hata Mesajı Güncelleyici
import re

file_path = r'c:\Users\adnan\Desktop\Projeler\sporcum-supabase\uyeyeni\admin.html'

# Dosyayı oku
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Eski mesajı bul ve değiştir
old_pattern = r'''// Olası çözümler
                        if \(errorDetail\.toLowerCase\(\)\.includes\('already'\) \|\| errorDetail\.toLowerCase\(\)\.includes\('exist'\)\) \{
                            errorMsg \+= `💡 Çözüm: Bu instance adı zaten mevcut\.\\n`;
                            errorMsg \+= `   → Farklı bir instance adı deneyin\\n`;
                            errorMsg \+= `   → Veya mevcut instance'ı kullanın`;'''

new_text = '''// Olası çözümler
                        const errorString = String(errorDetail).toLowerCase();
                        if (errorString.includes('already') || errorString.includes('in use') || errorString.includes('exist')) {
                            errorMsg += `⚠️ Bu instance adı zaten kullanılıyor!\\n\\n`;
                            errorMsg += `💡 Çözüm Seçenekleri:\\n`;
                            errorMsg += `   1️⃣ Farklı bir isim deneyin (örn: ${instanceName}2, ${instanceName}_yeni)\\n`;
                            errorMsg += `   2️⃣ Mevcut "${instanceName}" cihazını kullanın\\n`;
                            errorMsg += `   3️⃣ Eski cihazı silip yeniden oluşturun\\n\\n`;
                            errorMsg += `✅ Not: Mevcut cihazlarınız zaten çalışıyor!`;'''

# Değiştir
content = re.sub(old_pattern, new_text, content, flags=re.DOTALL)

# Kaydet
with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("✅ Hata mesajı güncellendi!")
