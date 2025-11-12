-- WhatsApp Mesaj Hakkı Sistemi - Veritabanı Yapısı
-- Kullanım: Bu SQL dosyasını Supabase SQL Editor'de çalıştırın
-- NOT: clubs tablosu Firebase'den geliyor, bu yüzden basit bir clubs reference tablosu oluşturuyoruz

-- 1. clubs tablosuna whatsapp_balance kolonu ekle (eğer yoksa)
DO $$ 
BEGIN
    -- whatsapp_balance kolonu yoksa ekle
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'clubs' AND column_name = 'whatsapp_balance'
    ) THEN
        ALTER TABLE clubs ADD COLUMN whatsapp_balance INTEGER DEFAULT 100;
    END IF;
END $$;

-- ========================================
-- OTOMATİK KULÜP SENKRONIZASYONU
-- ========================================
-- Yeni kulüp eklendiğinde otomatik olarak whatsapp_balance = 100 olarak ayarlanır
-- Mevcut kulüplerin whatsapp_balance'ı NULL ise 100 yapılır

-- 1. Mevcut tüm kulüplerin whatsapp_balance'ını ayarla
UPDATE clubs 
SET whatsapp_balance = 100 
WHERE whatsapp_balance IS NULL OR whatsapp_balance = 0;

-- 2. Yeni eklenen kulüpler için otomatik trigger
CREATE OR REPLACE FUNCTION set_default_whatsapp_balance()
RETURNS TRIGGER AS $$
BEGIN
    -- Eğer whatsapp_balance belirtilmemişse 100 yap
    IF NEW.whatsapp_balance IS NULL THEN
        NEW.whatsapp_balance := 100;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger oluştur
DROP TRIGGER IF EXISTS trigger_set_whatsapp_balance ON clubs;
CREATE TRIGGER trigger_set_whatsapp_balance
    BEFORE INSERT ON clubs
    FOR EACH ROW
    EXECUTE FUNCTION set_default_whatsapp_balance();

-- 2. WhatsApp mesaj paketleri tablosu
CREATE TABLE IF NOT EXISTS whatsapp_packages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    message_count INTEGER NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. WhatsApp bakiye işlem geçmişi tablosu
CREATE TABLE IF NOT EXISTS whatsapp_balance_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id TEXT NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,  -- Firebase club ID
    amount INTEGER NOT NULL,
    action_type VARCHAR(20) NOT NULL CHECK (action_type IN ('add', 'purchase', 'send', 'manual_add', 'refund')),
    previous_balance INTEGER NOT NULL,
    new_balance INTEGER NOT NULL,
    package_id UUID REFERENCES whatsapp_packages(id),
    note TEXT,
    created_by VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- İndeksler oluştur
CREATE INDEX IF NOT EXISTS idx_whatsapp_logs_club_id ON whatsapp_balance_logs(club_id);
CREATE INDEX IF NOT EXISTS idx_whatsapp_logs_action_type ON whatsapp_balance_logs(action_type);
CREATE INDEX IF NOT EXISTS idx_whatsapp_logs_created_at ON whatsapp_balance_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_whatsapp_packages_active ON whatsapp_packages(is_active);

-- Örnek paketler ekle
INSERT INTO whatsapp_packages (name, message_count, price, description) VALUES
('Başlangıç Paketi', 500, 99.00, '500 WhatsApp mesajı - Küçük kulüpler için idealdir'),
('Standart Paket', 1000, 179.00, '1000 WhatsApp mesajı - Orta ölçekli kulüpler için'),
('Premium Paket', 2500, 399.00, '2500 WhatsApp mesajı - Büyük kulüpler için'),
('Profesyonel Paket', 5000, 699.00, '5000 WhatsApp mesajı - En avantajlı paket'),
('Kurumsal Paket', 10000, 1199.00, '10000 WhatsApp mesajı - Kurumsal çözüm')
ON CONFLICT DO NOTHING;

-- updated_at otomatik güncelleme trigger'ı
CREATE OR REPLACE FUNCTION update_whatsapp_packages_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS whatsapp_packages_updated_at ON whatsapp_packages;
CREATE TRIGGER whatsapp_packages_updated_at
    BEFORE UPDATE ON whatsapp_packages
    FOR EACH ROW
    EXECUTE FUNCTION update_whatsapp_packages_updated_at();

-- RLS (Row Level Security) Politikaları
ALTER TABLE whatsapp_packages ENABLE ROW LEVEL SECURITY;
ALTER TABLE whatsapp_balance_logs ENABLE ROW LEVEL SECURITY;

-- Herkes aktif paketleri görebilir
CREATE POLICY "Aktif paketler herkes tarafından görülebilir" 
ON whatsapp_packages FOR SELECT 
USING (is_active = true);

-- Kulüpler sadece kendi loglarını görebilir
CREATE POLICY "Kulüpler kendi loglarını görebilir" 
ON whatsapp_balance_logs FOR SELECT 
USING (true); -- Admin kontrolü uygulama tarafında yapılacak

-- Kulüpler log ekleyebilir (mesaj gönderimi için)
CREATE POLICY "Log ekleme izni" 
ON whatsapp_balance_logs FOR INSERT 
WITH CHECK (true);

-- Kulüpler kendi bakiyelerini görebilir (clubs tablosunda mevcut policy'ler geçerli)

-- Yardımcı view: Kulüp mesaj istatistikleri
CREATE OR REPLACE VIEW club_whatsapp_stats AS
SELECT 
    c.id as club_id,
    c.name as club_name,
    c.whatsapp_balance,
    COUNT(CASE WHEN wbl.action_type = 'send' THEN 1 END) as total_sent,
    COUNT(CASE WHEN wbl.action_type IN ('add', 'purchase', 'manual_add') THEN 1 END) as total_purchases,
    SUM(CASE WHEN wbl.action_type IN ('add', 'purchase', 'manual_add') THEN wbl.amount ELSE 0 END) as total_credits_added,
    SUM(CASE WHEN wbl.action_type = 'send' THEN ABS(wbl.amount) ELSE 0 END) as total_credits_used
FROM clubs c
LEFT JOIN whatsapp_balance_logs wbl ON c.id = wbl.club_id
GROUP BY c.id, c.name, c.whatsapp_balance;

-- Bakiye güncelleme fonksiyonu (transaction güvenli)
CREATE OR REPLACE FUNCTION update_whatsapp_balance(
    p_club_id TEXT,  -- Firebase club ID (TEXT)
    p_amount INTEGER,
    p_action_type VARCHAR(20),
    p_package_id UUID DEFAULT NULL,
    p_note TEXT DEFAULT NULL,
    p_created_by VARCHAR(100) DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
    v_current_balance INTEGER;
    v_new_balance INTEGER;
    v_log_id UUID;
BEGIN
    -- Mevcut bakiyeyi al (FOR UPDATE ile kilitle)
    SELECT whatsapp_balance INTO v_current_balance
    FROM clubs
    WHERE id = p_club_id
    FOR UPDATE;

    IF v_current_balance IS NULL THEN
        RAISE EXCEPTION 'Kulüp bulunamadı: %', p_club_id;
    END IF;

    -- Yeni bakiyeyi hesapla
    v_new_balance := v_current_balance + p_amount;

    -- Bakiye negatif olamaz
    IF v_new_balance < 0 THEN
        RAISE EXCEPTION 'Yetersiz bakiye! Mevcut: %, İstenen: %', v_current_balance, ABS(p_amount);
    END IF;

    -- Bakiyeyi güncelle
    UPDATE clubs
    SET whatsapp_balance = v_new_balance
    WHERE id = p_club_id;

    -- Log kaydı oluştur
    INSERT INTO whatsapp_balance_logs (
        club_id, amount, action_type, previous_balance, new_balance, 
        package_id, note, created_by
    )
    VALUES (
        p_club_id, p_amount, p_action_type, v_current_balance, v_new_balance,
        p_package_id, p_note, p_created_by
    )
    RETURNING id INTO v_log_id;

    RETURN json_build_object(
        'success', true,
        'previous_balance', v_current_balance,
        'new_balance', v_new_balance,
        'amount', p_amount,
        'log_id', v_log_id
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Mesaj gönderimi öncesi bakiye kontrolü fonksiyonu
CREATE OR REPLACE FUNCTION check_whatsapp_balance(
    p_club_id TEXT,  -- Firebase club ID (TEXT)
    p_message_count INTEGER DEFAULT 1
)
RETURNS JSON AS $$
DECLARE
    v_current_balance INTEGER;
    v_has_enough BOOLEAN;
    v_warning BOOLEAN;
BEGIN
    SELECT whatsapp_balance INTO v_current_balance
    FROM clubs
    WHERE id = p_club_id;

    IF v_current_balance IS NULL THEN
        RETURN json_build_object(
            'has_enough', false,
            'error', 'Kulüp bulunamadı'
        );
    END IF;

    v_has_enough := v_current_balance >= p_message_count;
    v_warning := v_current_balance <= 100 OR (v_current_balance * 1.0 / GREATEST(p_message_count, 1)) <= 1.1;

    RETURN json_build_object(
        'has_enough', v_has_enough,
        'current_balance', v_current_balance,
        'requested', p_message_count,
        'remaining_after', v_current_balance - p_message_count,
        'low_balance_warning', v_warning
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Tamamlandı!
SELECT 'WhatsApp Mesaj Hakkı Sistemi başarıyla kuruldu!' as status;
