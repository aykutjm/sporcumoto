-- Supabase Schema for Sporcum CRM
-- This file creates all tables needed to migrate from Firebase

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Clubs Table
CREATE TABLE IF NOT EXISTS clubs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    icon TEXT DEFAULT '🏢',
    city TEXT,
    admin_email TEXT,
    admin_phone TEXT,
    admin_name TEXT,
    status TEXT DEFAULT 'active',
    member_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    source TEXT
);

-- 2. Settings Table (for club settings)
CREATE TABLE IF NOT EXISTS settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
    club_name TEXT,
    min_wait_time INTEGER DEFAULT 20,
    max_wait_time INTEGER DEFAULT 50,
    long_wait_trigger INTEGER DEFAULT 100,
    min_long_wait INTEGER DEFAULT 400,
    max_long_wait INTEGER DEFAULT 800,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(club_id)
);

-- 3. Users Table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT UNIQUE NOT NULL,
    username TEXT,
    password_hash TEXT, -- For custom auth
    role TEXT NOT NULL, -- 'admin', 'user', 'superadmin'
    club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    last_login TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT true
);

-- 4. Members Table
CREATE TABLE IF NOT EXISTS members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    birth_date DATE,
    age INTEGER,
    gender TEXT,
    parent1_name TEXT,
    parent1_phone TEXT,
    parent2_name TEXT,
    parent2_phone TEXT,
    address TEXT,
    branch TEXT, -- Spor branşı
    membership_type TEXT,
    registration_date DATE,
    payment_status TEXT DEFAULT 'pending',
    payment_amount DECIMAL(10,2),
    payment_frequency TEXT, -- 'monthly', 'yearly', etc
    last_payment_date DATE,
    next_payment_date DATE,
    notes TEXT,
    tags JSONB DEFAULT '[]',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Pre-registrations Table
CREATE TABLE IF NOT EXISTS pre_registrations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    birth_date DATE,
    age INTEGER,
    gender TEXT,
    parent1_name TEXT,
    parent1_phone TEXT,
    parent2_name TEXT,
    parent2_phone TEXT,
    address TEXT,
    branch TEXT,
    registration_date DATE,
    status TEXT DEFAULT 'pending',
    notes TEXT,
    tags JSONB DEFAULT '[]',
    converted_to_member BOOLEAN DEFAULT false,
    converted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. Groups Table
CREATE TABLE IF NOT EXISTS groups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    branch TEXT NOT NULL,
    coach TEXT,
    age_group TEXT,
    max_capacity INTEGER,
    current_count INTEGER DEFAULT 0,
    schedule_days JSONB DEFAULT '[]', -- ['Pazartesi', 'Çarşamba']
    schedule_times JSONB DEFAULT '{}', -- {'start': '10:00', 'end': '11:30'}
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. Schedules Table
CREATE TABLE IF NOT EXISTS schedules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
    member_id UUID REFERENCES members(id) ON DELETE CASCADE,
    group_id UUID REFERENCES groups(id) ON DELETE SET NULL,
    branch TEXT NOT NULL,
    day_of_week TEXT NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    coach TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. Attendance Records Table
CREATE TABLE IF NOT EXISTS attendance_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
    member_id UUID REFERENCES members(id) ON DELETE CASCADE,
    schedule_id UUID REFERENCES schedules(id) ON DELETE SET NULL,
    attendance_date DATE NOT NULL,
    status TEXT NOT NULL, -- 'present', 'absent', 'excused'
    notes TEXT,
    recorded_by UUID REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. CRM Leads Table
CREATE TABLE IF NOT EXISTS crm_leads (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    phone TEXT,
    email TEXT,
    source TEXT, -- 'whatsapp', 'phone', 'website', 'referral'
    status TEXT DEFAULT 'new', -- 'new', 'contacted', 'trial', 'negotiating', 'converted', 'lost'
    branch TEXT,
    age INTEGER,
    birth_date DATE,
    parent_name TEXT,
    parent_phone TEXT,
    notes TEXT,
    tags JSONB DEFAULT '[]',
    last_contact_date TIMESTAMPTZ,
    next_follow_up_date TIMESTAMPTZ,
    converted_to_member_id UUID REFERENCES members(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 10. CRM Tags Table
CREATE TABLE IF NOT EXISTS crm_tags (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    color TEXT DEFAULT '#4CAF50',
    icon TEXT DEFAULT '🏷️',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(club_id, name)
);

-- 11. WhatsApp Devices Table
CREATE TABLE IF NOT EXISTS whatsapp_devices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
    device_name TEXT NOT NULL,
    phone_number TEXT,
    api_key TEXT,
    api_url TEXT,
    is_active BOOLEAN DEFAULT true,
    is_default BOOLEAN DEFAULT false,
    last_connected TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 12. WhatsApp Incoming Calls Table
CREATE TABLE IF NOT EXISTS whatsapp_incoming_calls (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
    phone_number TEXT NOT NULL,
    caller_name TEXT,
    call_time TIMESTAMPTZ NOT NULL,
    duration INTEGER, -- in seconds
    is_answered BOOLEAN DEFAULT false,
    is_deleted BOOLEAN DEFAULT false,
    is_hidden BOOLEAN DEFAULT false,
    notes TEXT,
    converted_to_lead BOOLEAN DEFAULT false,
    lead_id UUID REFERENCES crm_leads(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 13. WhatsApp Incoming Messages Table
CREATE TABLE IF NOT EXISTS whatsapp_incoming_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
    from_number TEXT NOT NULL,
    to_number TEXT,
    message_text TEXT,
    message_type TEXT DEFAULT 'text', -- 'text', 'image', 'video', 'audio', 'document'
    media_url TEXT,
    timestamp TIMESTAMPTZ NOT NULL,
    is_read BOOLEAN DEFAULT false,
    webhook_data JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 14. WhatsApp Messages Table (Sent)
CREATE TABLE IF NOT EXISTS whatsapp_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
    to_number TEXT NOT NULL,
    message_text TEXT,
    device_id UUID REFERENCES whatsapp_devices(id),
    status TEXT DEFAULT 'pending', -- 'pending', 'sent', 'delivered', 'failed'
    sent_at TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ,
    error_message TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 15. Sent Messages (History/Log)
CREATE TABLE IF NOT EXISTS sent_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
    recipient_phone TEXT NOT NULL,
    recipient_name TEXT,
    message_text TEXT NOT NULL,
    message_type TEXT DEFAULT 'whatsapp', -- 'whatsapp', 'sms'
    sent_by UUID REFERENCES users(id),
    sent_at TIMESTAMPTZ DEFAULT NOW(),
    status TEXT DEFAULT 'sent',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 16. Message Queue Table
CREATE TABLE IF NOT EXISTS message_queue (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
    to_number TEXT NOT NULL,
    message_text TEXT NOT NULL,
    device_id UUID REFERENCES whatsapp_devices(id),
    priority INTEGER DEFAULT 0,
    scheduled_at TIMESTAMPTZ,
    status TEXT DEFAULT 'pending', -- 'pending', 'processing', 'sent', 'failed'
    retry_count INTEGER DEFAULT 0,
    max_retries INTEGER DEFAULT 3,
    error_message TEXT,
    sent_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 17. Scheduled Messages Table
CREATE TABLE IF NOT EXISTS scheduled_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
    recipient_phone TEXT NOT NULL,
    recipient_name TEXT,
    message_text TEXT NOT NULL,
    scheduled_for TIMESTAMPTZ NOT NULL,
    status TEXT DEFAULT 'scheduled', -- 'scheduled', 'sent', 'cancelled', 'failed'
    sent_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 18. Campaigns Table
CREATE TABLE IF NOT EXISTS campaigns (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
    campaign_name TEXT NOT NULL,
    message_text TEXT NOT NULL,
    target_audience JSONB, -- Filter criteria
    recipient_count INTEGER DEFAULT 0,
    sent_count INTEGER DEFAULT 0,
    status TEXT DEFAULT 'draft', -- 'draft', 'scheduled', 'sending', 'completed', 'cancelled'
    scheduled_for TIMESTAMPTZ,
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 19. Tasks Table
CREATE TABLE IF NOT EXISTS tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    priority TEXT DEFAULT 'medium', -- 'low', 'medium', 'high', 'urgent'
    status TEXT DEFAULT 'pending', -- 'pending', 'in_progress', 'completed', 'cancelled'
    assigned_to UUID REFERENCES users(id),
    due_date TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 20. Expenses Table
CREATE TABLE IF NOT EXISTS expenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
    category TEXT NOT NULL,
    description TEXT,
    amount DECIMAL(10,2) NOT NULL,
    expense_date DATE NOT NULL,
    payment_method TEXT,
    receipt_url TEXT,
    recorded_by UUID REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 21. Products Table (for sales/inventory)
CREATE TABLE IF NOT EXISTS products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
    product_name TEXT NOT NULL,
    category TEXT,
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INTEGER DEFAULT 0,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 22. Webhooks Table
CREATE TABLE IF NOT EXISTS webhooks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
    webhook_url TEXT NOT NULL,
    webhook_type TEXT, -- 'whatsapp', 'payment', etc
    is_active BOOLEAN DEFAULT true,
    last_triggered TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 23. User Activities Table (for audit logs)
CREATE TABLE IF NOT EXISTS user_activities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    activity_type TEXT NOT NULL, -- 'login', 'create', 'update', 'delete'
    entity_type TEXT, -- 'member', 'lead', 'message', etc
    entity_id UUID,
    description TEXT,
    ip_address TEXT,
    user_agent TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 24. Holidays Table
CREATE TABLE IF NOT EXISTS holidays (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
    holiday_name TEXT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 25. Branches Table
CREATE TABLE IF NOT EXISTS branches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
    branch_name TEXT NOT NULL,
    icon TEXT DEFAULT '🎾',
    color TEXT DEFAULT '#4CAF50',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(club_id, branch_name)
);

-- Indexes for better performance
CREATE INDEX idx_members_club_id ON members(club_id);
CREATE INDEX idx_members_phone ON members(parent1_phone, parent2_phone);
CREATE INDEX idx_members_branch ON members(branch);
CREATE INDEX idx_pre_registrations_club_id ON pre_registrations(club_id);
CREATE INDEX idx_schedules_club_id ON schedules(club_id);
CREATE INDEX idx_schedules_member_id ON schedules(member_id);
CREATE INDEX idx_crm_leads_club_id ON crm_leads(club_id);
CREATE INDEX idx_crm_leads_status ON crm_leads(status);
CREATE INDEX idx_crm_leads_phone ON crm_leads(phone);
CREATE INDEX idx_whatsapp_calls_club_id ON whatsapp_incoming_calls(club_id);
CREATE INDEX idx_whatsapp_calls_phone ON whatsapp_incoming_calls(phone_number);
CREATE INDEX idx_whatsapp_messages_club_id ON whatsapp_messages(club_id);
CREATE INDEX idx_message_queue_status ON message_queue(status);
CREATE INDEX idx_message_queue_scheduled ON message_queue(scheduled_at);
CREATE INDEX idx_attendance_date ON attendance_records(attendance_date);
CREATE INDEX idx_attendance_member ON attendance_records(member_id);
CREATE INDEX idx_users_club_id ON users(club_id);
CREATE INDEX idx_users_email ON users(email);

-- Create triggers for updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply triggers to all tables with updated_at column
CREATE TRIGGER update_clubs_updated_at BEFORE UPDATE ON clubs FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_settings_updated_at BEFORE UPDATE ON settings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_members_updated_at BEFORE UPDATE ON members FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_pre_registrations_updated_at BEFORE UPDATE ON pre_registrations FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_groups_updated_at BEFORE UPDATE ON groups FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_schedules_updated_at BEFORE UPDATE ON schedules FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_crm_leads_updated_at BEFORE UPDATE ON crm_leads FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_crm_tags_updated_at BEFORE UPDATE ON crm_tags FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security (RLS)
ALTER TABLE clubs ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE members ENABLE ROW LEVEL SECURITY;
ALTER TABLE pre_registrations ENABLE ROW LEVEL SECURITY;
ALTER TABLE schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE crm_leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE crm_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE whatsapp_devices ENABLE ROW LEVEL SECURITY;
ALTER TABLE whatsapp_incoming_calls ENABLE ROW LEVEL SECURITY;
ALTER TABLE whatsapp_messages ENABLE ROW LEVEL SECURITY;

-- RLS Policies (Basic - adjust based on your needs)
-- Superadmin can see all
CREATE POLICY "Superadmins can do everything" ON clubs
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role = 'superadmin'
        )
    );

-- Users can only see their club's data
CREATE POLICY "Users can see their club" ON members
    FOR SELECT USING (
        club_id IN (
            SELECT club_id FROM users WHERE id = auth.uid()
        )
    );

-- Add more policies as needed for each table

COMMENT ON TABLE clubs IS 'Sports clubs/organizations';
COMMENT ON TABLE members IS 'Active club members';
COMMENT ON TABLE pre_registrations IS 'Pre-registered candidates not yet converted to members';
COMMENT ON TABLE crm_leads IS 'CRM system leads and potential customers';
COMMENT ON TABLE whatsapp_devices IS 'WhatsApp API devices/connections';
COMMENT ON TABLE message_queue IS 'Queue for scheduled/pending messages';

