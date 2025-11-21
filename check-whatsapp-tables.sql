-- ✅ TABLOLARIN YAPISI KONTROL
-- Bu SQL'i Supabase SQL Editor'de çalıştırın

-- 1️⃣ Tabloların var olup olmadığını kontrol et
SELECT 
    table_name,
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = t.table_name) as column_count
FROM information_schema.tables t
WHERE table_schema = 'public' 
AND table_name IN ('whatsapp_incoming_calls', 'whatsapp_incoming_messages')
ORDER BY table_name;

-- 2️⃣ Çağrılar tablosu kolonları
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'whatsapp_incoming_calls'
ORDER BY ordinal_position;

-- 3️⃣ Mesajlar tablosu kolonları
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'whatsapp_incoming_messages'
ORDER BY ordinal_position;

-- 4️⃣ Index'leri kontrol et
SELECT 
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
AND tablename IN ('whatsapp_incoming_calls', 'whatsapp_incoming_messages')
ORDER BY tablename, indexname;

-- 5️⃣ RLS politikalarını kontrol et
SELECT 
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies
WHERE schemaname = 'public'
AND tablename IN ('whatsapp_incoming_calls', 'whatsapp_incoming_messages')
ORDER BY tablename, policyname;

-- 6️⃣ RLS aktif mi kontrol et
SELECT 
    schemaname,
    tablename,
    rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
AND tablename IN ('whatsapp_incoming_calls', 'whatsapp_incoming_messages');
