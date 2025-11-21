#!/usr/bin/env python3
# -*- coding: utf-8 -*-

file_path = r'c:\Users\adnan\Desktop\Projeler\sporcum-supabase\uyeyeni\admin.html'

# Read file
with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
    content = f.read()

# Fix remaining broken emojis
content = content.replace('�&#128221;&#128221; Açıklama', '📝 Açıklama')

# Fix Tutar label if still broken
lines = content.split('\n')
for i, line in enumerate(lines):
    if 'Tutar (₺)' in line and '💵' not in line:
        lines[i] = line.replace('label style="display: block; margin-bottom: 8px; font-weight: 600; color: #333;">�', 'label style="display: block; margin-bottom: 8px; font-weight: 600; color: #333;">�')

content = '\n'.join(lines)

# Write back
with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("✅ Kalan bozuk emojiler düzeltildi!")
