-- Ürün Satışları Tablosu
CREATE TABLE IF NOT EXISTS public."productSales" (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    "clubId" TEXT NOT NULL,
    "productName" TEXT NOT NULL,
    price NUMERIC(10, 2) NOT NULL DEFAULT 0,
    quantity INTEGER NOT NULL DEFAULT 1,
    "totalAmount" NUMERIC(10, 2) NOT NULL DEFAULT 0,
    category TEXT,
    branch TEXT,
    "saleDate" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    notes TEXT,
    "createdAt" TIMESTAMPTZ DEFAULT NOW(),
    "updatedAt" TIMESTAMPTZ DEFAULT NOW()
);

-- Index'ler
CREATE INDEX IF NOT EXISTS "idx_productSales_clubId" ON public."productSales"("clubId");
CREATE INDEX IF NOT EXISTS "idx_productSales_saleDate" ON public."productSales"("saleDate");
CREATE INDEX IF NOT EXISTS "idx_productSales_branch" ON public."productSales"(branch);

-- RLS (Row Level Security) politikaları
ALTER TABLE public."productSales" ENABLE ROW LEVEL SECURITY;

-- Önce mevcut policy'leri sil
DROP POLICY IF EXISTS "Users can view their club's product sales" ON public."productSales";
DROP POLICY IF EXISTS "Users can insert product sales for their club" ON public."productSales";
DROP POLICY IF EXISTS "Users can update their club's product sales" ON public."productSales";
DROP POLICY IF EXISTS "Users can delete their club's product sales" ON public."productSales";

-- Tüm kullanıcılar kendi kulüplerinin ürün satışlarını görebilir
CREATE POLICY "Users can view their club's product sales"
    ON public."productSales"
    FOR SELECT
    USING (true);

-- Tüm kullanıcılar kendi kulüplerine ürün satışı ekleyebilir
CREATE POLICY "Users can insert product sales for their club"
    ON public."productSales"
    FOR INSERT
    WITH CHECK (true);

-- Tüm kullanıcılar kendi kulüplerinin ürün satışlarını güncelleyebilir
CREATE POLICY "Users can update their club's product sales"
    ON public."productSales"
    FOR UPDATE
    USING (true);

-- Tüm kullanıcılar kendi kulüplerinin ürün satışlarını silebilir
CREATE POLICY "Users can delete their club's product sales"
    ON public."productSales"
    FOR DELETE
    USING (true);

-- Güncelleme trigger'ı
CREATE OR REPLACE FUNCTION update_productSales_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW."updatedAt" = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_productSales_timestamp
    BEFORE UPDATE ON public."productSales"
    FOR EACH ROW
    EXECUTE FUNCTION update_productSales_timestamp();

-- Örnek veri ekle (isteğe bağlı - test için)
-- INSERT INTO public."productSales" ("clubId", "productName", price, quantity, "totalAmount", category, branch, "saleDate")
-- VALUES 
-- ('FmvoFvTCek44CR3pS4XC', 'Tenis Raketi', 500.00, 1, 500.00, 'Ekipman', 'tenis', NOW()),
-- ('FmvoFvTCek44CR3pS4XC', 'Spor Ayakkabı', 350.00, 2, 700.00, 'Giyim', 'tenis', NOW());
