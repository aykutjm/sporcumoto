# -*- coding: utf-8 -*-
import re

file_path = r'c:\Users\adnan\Desktop\Projeler\sporcum-supabase\uyeyeni\admin.html'

# Read the file
with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
    content = f.read()

# Define the old pattern (with broken emojis as they might appear)
old_section = '''                        }
                        
                        html += `
                            <div style="padding: 12px; background: #ffebee; border-left: 4px solid #d32f2f; border-radius: 8px;">
                                <div style="display: flex; justify-content: space-between; align-items: start;">
                                    <div style="flex: 1;">
                                        <div style="font-weight: 600; margin-bottom: 4px; color: #333;">'''

# Define the new replacement
new_section = '''                        }
                        
                        // Escape HTML ve özel karakterler (başarısız mesajlar)
                        const escapedFailedMessage = message.message
                            .replace(/&/g, '&amp;')
                            .replace(/</g, '&lt;')
                            .replace(/>/g, '&gt;')
                            .replace(/"/g, '&quot;')
                            .replace(/'/g, '&#39;');
                        
                        const escapedFailedContact = contactName
                            .replace(/&/g, '&amp;')
                            .replace(/</g, '&lt;')
                            .replace(/>/g, '&gt;')
                            .replace(/"/g, '&quot;')
                            .replace(/'/g, '&#39;');
                        
                        html += `
                            <div style="padding: 12px; background: #ffebee; border-left: 4px solid #d32f2f; border-radius: 8px;">
                                <div style="display: flex; justify-content: space-between; align-items: start;">
                                    <div style="flex: 1;">
                                        <div style="font-weight: 600; margin-bottom: 4px; color: #333;">'''

# Replace
if old_section in content:
    content = content.replace(old_section, new_section)
    print("✓ Found and replaced section header")
else:
    print("✗ Could not find exact match for section header")

# Now fix the emoji lines using regex (to handle any corrupted characters)
# Pattern 1: Fix the contact name line with emoji
pattern1 = r'(<div style="font-weight: 600; margin-bottom: 4px; color: #333;">)\s*[^\$]*\$\{contactName\}'
replacement1 = r'\1\n                                            👤 ${escapedFailedContact}'

content = re.sub(pattern1, replacement1, content, count=1, flags=re.MULTILINE)
print("✓ Fixed contact name emoji")

# Pattern 2: Fix the phone emoji line
pattern2 = r'(<span style="font-weight: normal; color: #666; margin-left: 8px;">)[^\$]*\$\{message\.phone\}'
replacement2 = r'\1📞 ${message.phone}'

content = re.sub(pattern2, replacement2, content, count=1, flags=re.MULTILINE)
print("✓ Fixed phone emoji")

# Pattern 3: Fix the message div to use escaped version and add inline editing
pattern3 = r'<div style="font-size: 13px; color: #555; margin-bottom: 8px; padding: 8px; background: white; border-radius: 4px; white-space: pre-wrap;">\$\{message\.message\.substring\(0, 150\)\}\$\{message\.message\.length > 150 \? \'...\' : \'\'\}</div>'
replacement3 = '<div id="msg-${message.id}" onclick="makeMessageEditable(\'${message.id}\')" style="font-size: 13px; color: #555; margin-bottom: 8px; padding: 8px; background: white; border-radius: 4px; white-space: pre-wrap; cursor: pointer; transition: all 0.2s;" onmouseover="this.style.background=\'#f5f5f5\'" onmouseout="this.style.background=\'white\'">${escapedFailedMessage}</div>'

content = re.sub(pattern3, replacement3, content, count=1)
print("✓ Fixed message div with inline editing")

# Write back
with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("\n✅ File updated successfully!")
