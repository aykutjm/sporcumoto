-- Gelir kategorileri tablosu oluştur
CREATE TABLE IF NOT EXISTS public."incomeCategories" (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "clubId" TEXT NOT NULL,
    name TEXT NOT NULL,
    icon TEXT DEFAULT '📦',
    "createdAt" TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE("clubId", name)
);

-- Index ekle
CREATE INDEX IF NOT EXISTS "idx_incomeCategories_clubId" ON public."incomeCategories"("clubId");

-- RLS (Row Level Security) politikaları
ALTER TABLE public."incomeCategories" ENABLE ROW LEVEL SECURITY;

CREATE POLICY "incomeCategories_select_policy" ON public."incomeCategories"
    FOR SELECT USING (true);

CREATE POLICY "incomeCategories_insert_policy" ON public."incomeCategories"
    FOR INSERT WITH CHECK (true);

CREATE POLICY "incomeCategories_update_policy" ON public."incomeCategories"
    FOR UPDATE USING (true);

CREATE POLICY "incomeCategories_delete_policy" ON public."incomeCategories"
    FOR DELETE USING (true);

-- Yorum ekle
COMMENT ON TABLE public."incomeCategories" IS 'Kulüpler için özelleştirilebilir gelir kategorileri';
COMMENT ON COLUMN public."incomeCategories".id IS 'Kategori benzersiz ID';
COMMENT ON COLUMN public."incomeCategories"."clubId" IS 'Kategoriye ait kulüp ID';
COMMENT ON COLUMN public."incomeCategories".name IS 'Kategori adı';
COMMENT ON COLUMN public."incomeCategories".icon IS 'Kategori ikonu (emoji)';
COMMENT ON COLUMN public."incomeCategories"."createdAt" IS 'Kategori oluşturulma zamanı';
