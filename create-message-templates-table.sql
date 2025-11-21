-- message_templates tablosunu oluştur

CREATE TABLE IF NOT EXISTS message_templates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  club_id text NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
  template_name text NOT NULL,
  category text NOT NULL, -- 'missed_call', 'overdue_payment', 'absence', 'upcoming_payment', 'trial_lesson'
  message text NOT NULL,
  is_active boolean DEFAULT true,
  send_days integer[] DEFAULT '{1,2,3,4,5}', -- 0=Pazar, 1=Pazartesi, ..., 6=Cumartesi
  send_time time DEFAULT '09:00:00',
  days_before integer DEFAULT 3, -- Yaklaşan ödemeler için kaç gün önceden mesaj gönderilecek
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- İndeksler
CREATE INDEX IF NOT EXISTS idx_message_templates_club_id ON message_templates(club_id);
CREATE INDEX IF NOT EXISTS idx_message_templates_category ON message_templates(category);
CREATE INDEX IF NOT EXISTS idx_message_templates_is_active ON message_templates(is_active);

-- RLS Politikaları
ALTER TABLE message_templates ENABLE ROW LEVEL SECURITY;

-- Servis rolü için tam erişim
CREATE POLICY "Service role has full access to message_templates"
  ON message_templates
  USING (true)
  WITH CHECK (true);

-- Authenticated kullanıcılar okuyabilir
CREATE POLICY "Authenticated users can read message_templates"
  ON message_templates FOR SELECT
  TO authenticated
  USING (true);

-- Authenticated kullanıcılar ekleyebilir
CREATE POLICY "Authenticated users can insert message_templates"
  ON message_templates FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Authenticated kullanıcılar güncelleyebilir
CREATE POLICY "Authenticated users can update message_templates"
  ON message_templates FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Authenticated kullanıcılar silebilir
CREATE POLICY "Authenticated users can delete message_templates"
  ON message_templates FOR DELETE
  TO authenticated
  USING (true);

COMMENT ON TABLE message_templates IS 'WhatsApp otomatik mesaj şablonları';
COMMENT ON COLUMN message_templates.category IS 'Mesaj kategorisi: missed_call, overdue_payment, absence, upcoming_payment, trial_lesson';
COMMENT ON COLUMN message_templates.send_days IS 'Mesajın gönderileceği günler (0=Pazar, 1=Pazartesi, ..., 6=Cumartesi)';
COMMENT ON COLUMN message_templates.send_time IS 'Mesajın gönderileceği saat (HH:MM:SS formatında)';
COMMENT ON COLUMN message_templates.days_before IS 'Yaklaşan ödemeler için kaç gün önceden uyarı gönderilecek (varsayılan: 3 gün)';
