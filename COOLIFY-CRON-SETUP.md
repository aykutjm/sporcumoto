# Coolify Cron Job Kurulumu
# Auto-reply scripti için her 2 dakikada çalışacak

## ADIMLAR:

1. Coolify Dashboard > Projects > Supabase Projeniz
2. Sol menüden "Scheduled Tasks" veya "Cron Jobs" bölümü
3. "Add Scheduled Task" tıklayın

### Cron Job Ayarları:
```
Name: auto-reply-missed-calls
Schedule: */2 * * * *  (Her 2 dakikada)
Command: cd /app && node auto-reply-missed-calls.js
Environment: production
```

4. Environment Variables ekleyin:
   - SUPABASE_URL=https://supabase.edu-ai.online
   - SUPABASE_SERVICE_ROLE_KEY=<service-role-key>

5. Save & Enable

## NOT:
Eğer Coolify'da cron job özelliği yoksa, sunucunuza SSH ile bağlanıp 
sistem cron job'u olarak ekleyebilirsiniz:

```bash
crontab -e
# Ekleyin:
*/2 * * * * cd /path/to/project && node auto-reply-missed-calls.js >> /var/log/auto-reply.log 2>&1
```

Bu yöntemle bilgisayarınız kapalı olsa bile sunucuda çalışmaya devam eder.
