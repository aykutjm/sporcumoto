-- Otomatik mesaj ayarları tablosu (her şube için ayrı ayarlar)
CREATE TABLE IF NOT EXISTS "autoMessageSettings" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "branchId" UUID NOT NULL REFERENCES "branches"("id") ON DELETE CASCADE,
  "messageType" TEXT NOT NULL, -- 'missed_call', 'overdue_payment', 'absence', 'upcoming_payment', 'trial_lesson'
  "isActive" BOOLEAN DEFAULT true,
  "triggerDays" INTEGER DEFAULT 0, -- Kaç gün sonra/önce tetiklenecek
  "templateId" UUID REFERENCES "messageTemplates"("id") ON DELETE SET NULL,
  "lastCheckedAt" TIMESTAMP WITH TIME ZONE,
  "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  "updatedAt" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Her şube için her mesaj tipi sadece 1 kez olabilir
  UNIQUE ("branchId", "messageType")
);

-- Index'ler
CREATE INDEX IF NOT EXISTS "idx_autoMessageSettings_branchId" ON "autoMessageSettings"("branchId");
CREATE INDEX IF NOT EXISTS "idx_autoMessageSettings_messageType" ON "autoMessageSettings"("messageType");
CREATE INDEX IF NOT EXISTS "idx_autoMessageSettings_isActive" ON "autoMessageSettings"("isActive");

-- Yorumlar
COMMENT ON TABLE "autoMessageSettings" IS 'Şube bazında otomatik mesaj gönderim ayarları';
COMMENT ON COLUMN "autoMessageSettings"."messageType" IS 'Mesaj tipi: missed_call, overdue_payment, absence, upcoming_payment, trial_lesson';
COMMENT ON COLUMN "autoMessageSettings"."triggerDays" IS 'Tetikleme gün sayısı. Pozitif: ileri tarih, Negatif: geçmiş tarih. Örn: -2 = 2 gün geçmiş, +7 = 7 gün sonra';
COMMENT ON COLUMN "autoMessageSettings"."lastCheckedAt" IS 'Son kontrol zamanı (tekrar mesaj göndermemek için)';

-- RLS Policies
ALTER TABLE "autoMessageSettings" ENABLE ROW LEVEL SECURITY;

-- Admin her şeyi görebilir
CREATE POLICY "Admin can view all auto message settings"
  ON "autoMessageSettings" FOR SELECT
  USING (
    auth.uid() IN (
      SELECT "userId" FROM "userBranches" 
      WHERE "role" = 'admin'
    )
  );

-- Şube yöneticileri sadece kendi şubelerini görebilir
CREATE POLICY "Branch managers can view their branch auto message settings"
  ON "autoMessageSettings" FOR SELECT
  USING (
    "branchId" IN (
      SELECT "branchId" FROM "userBranches" 
      WHERE "userId" = auth.uid()
    )
  );

-- Admin ve şube yöneticileri güncelleyebilir
CREATE POLICY "Admin and branch managers can update auto message settings"
  ON "autoMessageSettings" FOR UPDATE
  USING (
    auth.uid() IN (
      SELECT ub."userId" FROM "userBranches" ub
      WHERE ub."branchId" = "autoMessageSettings"."branchId"
        AND ub."role" IN ('admin', 'manager')
    )
  );

-- Admin ve şube yöneticileri ekleyebilir
CREATE POLICY "Admin and branch managers can insert auto message settings"
  ON "autoMessageSettings" FOR INSERT
  WITH CHECK (
    auth.uid() IN (
      SELECT ub."userId" FROM "userBranches" ub
      WHERE ub."branchId" = "autoMessageSettings"."branchId"
        AND ub."role" IN ('admin', 'manager')
    )
  );

-- Service role her şeyi yapabilir (otomatik sistem için)
CREATE POLICY "Service role has full access to auto message settings"
  ON "autoMessageSettings" FOR ALL
  USING (current_setting('request.jwt.claims', true)::json->>'role' = 'service_role')
  WITH CHECK (current_setting('request.jwt.claims', true)::json->>'role' = 'service_role');

-- Default ayarlar ekle (tüm şubeler için)
INSERT INTO "autoMessageSettings" ("branchId", "messageType", "isActive", "triggerDays", "templateId")
SELECT 
  b."id",
  message_type.type,
  CASE 
    WHEN message_type.type = 'missed_call' THEN true  -- Cevapsız çağrı aktif
    ELSE false  -- Diğerleri pasif (manuel açılacak)
  END,
  CASE 
    WHEN message_type.type = 'overdue_payment' THEN -2  -- 2 gün gecikmiş
    WHEN message_type.type = 'absence' THEN -3          -- 3 gün devamsız
    WHEN message_type.type = 'upcoming_payment' THEN 7  -- 7 gün sonra
    WHEN message_type.type = 'trial_lesson' THEN 1      -- 1 gün sonra (yarın)
    ELSE 0
  END,
  NULL  -- templateId şimdilik boş (CRM'den bağlanacak)
FROM "branches" b
CROSS JOIN (
  VALUES 
    ('missed_call'),
    ('overdue_payment'),
    ('absence'),
    ('upcoming_payment'),
    ('trial_lesson')
) AS message_type(type)
ON CONFLICT ("branchId", "messageType") DO NOTHING;

-- Updated at trigger
CREATE OR REPLACE FUNCTION update_autoMessageSettings_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW."updatedAt" = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER autoMessageSettings_updated_at
  BEFORE UPDATE ON "autoMessageSettings"
  FOR EACH ROW
  EXECUTE FUNCTION update_autoMessageSettings_updated_at();
