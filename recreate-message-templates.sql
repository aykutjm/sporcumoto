-- message_templates tablosunu sıfırdan oluştur (DROP + CREATE)

DROP TABLE IF EXISTS message_templates CASCADE;

CREATE TABLE message_templates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  club_id text NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
  template_name text NOT NULL,
  category text NOT NULL,
  message text NOT NULL,
  is_active boolean DEFAULT true,
  send_days integer[] DEFAULT '{1,2,3,4,5}',
  send_time time DEFAULT '09:00:00',
  days_before integer DEFAULT 3,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX idx_message_templates_club_id ON message_templates(club_id);
CREATE INDEX idx_message_templates_category ON message_templates(category);
CREATE INDEX idx_message_templates_is_active ON message_templates(is_active);

ALTER TABLE message_templates ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Service role has full access to message_templates"
  ON message_templates USING (true) WITH CHECK (true);

CREATE POLICY "Authenticated users can read message_templates"
  ON message_templates FOR SELECT TO authenticated USING (true);

CREATE POLICY "Authenticated users can insert message_templates"
  ON message_templates FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Authenticated users can update message_templates"
  ON message_templates FOR UPDATE TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Authenticated users can delete message_templates"
  ON message_templates FOR DELETE TO authenticated USING (true);
