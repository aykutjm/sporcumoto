-- Service Role Key Bilgisini SQL'den Al
-- NOT: Bu key hassas bilgidir, dikkatli kullanın!

-- PostgreSQL JWT secret'ını göster (bu ile service role key oluşturulmuş olabilir)
SHOW app.settings.jwt_secret;

-- Alternatif: Mevcut role'leri ve ayarları göster
SELECT 
    rolname,
    rolsuper,
    rolinherit,
    rolcreaterole,
    rolcreatedb,
    rolcanlogin
FROM pg_roles
WHERE rolname IN ('anon', 'authenticated', 'service_role', 'postgres')
ORDER BY rolname;

-- Supabase API settings'i kontrol et
SELECT current_setting('app.settings.jwt_secret', true) as jwt_secret;
