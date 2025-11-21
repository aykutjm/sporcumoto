@echo off
REM Auto Reply Missed Calls - Batch Runner
REM Her 2 dakikada bir Task Scheduler ile çalışır

cd /d C:\Users\adnan\Desktop\Projeler\sporcum-supabase
node auto-reply-missed-calls.js >> auto-reply.log 2>&1
