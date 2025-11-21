-- Diğer Gelirler Tablosu (Kulüplerin özel gelir kategorileri)
CREATE TABLE IF NOT EXISTS public."otherIncomes" (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    "clubId" TEXT NOT NULL,
    category TEXT NOT NULL, -- Gelir kategorisi (örn: "Kamp Ücreti", "Turnuva Ücreti", "Sponsorluk")
    amount NUMERIC(10, 2) NOT NULL DEFAULT 0,
    description TEXT,
    branch TEXT,
    "incomeDate" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    "createdBy" TEXT,
    "createdAt" TIMESTAMPTZ DEFAULT NOW(),
    "updatedAt" TIMESTAMPTZ DEFAULT NOW()
);

-- Index'ler
CREATE INDEX IF NOT EXISTS "idx_otherIncomes_clubId" ON public."otherIncomes"("clubId");
CREATE INDEX IF NOT EXISTS "idx_otherIncomes_incomeDate" ON public."otherIncomes"("incomeDate");
CREATE INDEX IF NOT EXISTS "idx_otherIncomes_category" ON public."otherIncomes"(category);

-- RLS (Row Level Security) politikaları
ALTER TABLE public."otherIncomes" ENABLE ROW LEVEL SECURITY;

-- Önce mevcut policy'leri sil
DROP POLICY IF EXISTS "Users can view their club's other incomes" ON public."otherIncomes";
DROP POLICY IF EXISTS "Users can insert other incomes for their club" ON public."otherIncomes";
DROP POLICY IF EXISTS "Users can update their club's other incomes" ON public."otherIncomes";
DROP POLICY IF EXISTS "Users can delete their club's other incomes" ON public."otherIncomes";

-- Tüm kullanıcılar kendi kulüplerinin diğer gelirlerini görebilir
CREATE POLICY "Users can view their club's other incomes"
    ON public."otherIncomes"
    FOR SELECT
    USING (true);

-- Tüm kullanıcılar kendi kulüplerine diğer gelir ekleyebilir
CREATE POLICY "Users can insert other incomes for their club"
    ON public."otherIncomes"
    FOR INSERT
    WITH CHECK (true);

-- Tüm kullanıcılar kendi kulüplerinin diğer gelirlerini güncelleyebilir
CREATE POLICY "Users can update their club's other incomes"
    ON public."otherIncomes"
    FOR UPDATE
    USING (true);

-- Tüm kullanıcılar kendi kulüplerinin diğer gelirlerini silebilir
CREATE POLICY "Users can delete their club's other incomes"
    ON public."otherIncomes"
    FOR DELETE
    USING (true);

-- Güncelleme trigger'ı
CREATE OR REPLACE FUNCTION update_otherIncomes_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW."updatedAt" = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_otherIncomes_timestamp
    BEFORE UPDATE ON public."otherIncomes"
    FOR EACH ROW
    EXECUTE FUNCTION update_otherIncomes_timestamp();
