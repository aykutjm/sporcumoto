-- Supabase Schema - Firebase Compatible (Türkçe Field Adları)
-- Firebase'deki mevcut yapıyla %100 uyumlu

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Clubs Table (Firebase yapısıyla)
CREATE TABLE IF NOT EXISTS clubs (
    id TEXT PRIMARY KEY,
    name TEXT,
    icon TEXT,
    city TEXT,
    adminEmail TEXT,
    adminName TEXT,
    adminPhone TEXT,
    phone TEXT,
    description TEXT,
    status TEXT DEFAULT 'active',
    active BOOLEAN DEFAULT true,
    memberCount INTEGER DEFAULT 0,
    crmEnabled BOOLEAN DEFAULT false,
    expenseCategories JSONB DEFAULT '[]',
    productCategories JSONB DEFAULT '[]',
    createdAt TIMESTAMPTZ,
    createdBy TEXT,
    updatedAt TIMESTAMPTZ,
    updatedBy TEXT
);

-- 2. Settings Table (Firebase yapısıyla)
CREATE TABLE IF NOT EXISTS settings (
    id TEXT PRIMARY KEY,
    clubId TEXT,
    list JSONB,
    branches JSONB,
    courts JSONB,
    minWaitTime INTEGER,
    maxWaitTime INTEGER,
    longWaitTrigger INTEGER,
    minLongWait INTEGER,
    maxLongWait INTEGER,
    clubName TEXT,
    absence JSONB,
    createdAt TIMESTAMPTZ,
    updatedAt TIMESTAMPTZ
);

-- 3. Users Table (Firebase yapısıyla)
CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY,
    email TEXT,
    username TEXT,
    password TEXT,
    role TEXT,
    clubId TEXT,
    club_name TEXT,
    fullName TEXT,
    isActive BOOLEAN DEFAULT true,
    createdAt TIMESTAMPTZ,
    updatedAt TIMESTAMPTZ,
    lastLogin TIMESTAMPTZ
);

-- 4. Members Table (Firebase yapısıyla - Türkçe field adları)
CREATE TABLE IF NOT EXISTS members (
    id TEXT PRIMARY KEY,
    clubId TEXT,
    "Ad_Soyad" TEXT,
    "Resit_Olmayan_Adi_Soyadi" TEXT,
    "Telefon" TEXT,
    "Email" TEXT,
    "TC_No" TEXT,
    "Dogum_Tarihi" TIMESTAMPTZ,
    "Brans" TEXT,
    "Uyelik_Baslangic_Tarihi" TIMESTAMPTZ,
    status TEXT DEFAULT 'active',
    memberType TEXT,
    preRegistrationId TEXT,
    groupId TEXT,
    scheduleIds JSONB DEFAULT '[]',
    notes TEXT,
    tags JSONB DEFAULT '[]',
    paymentInfo JSONB,
    lastPaymentDate TIMESTAMPTZ,
    nextPaymentDate TIMESTAMPTZ,
    createdAt TIMESTAMPTZ,
    updatedAt TIMESTAMPTZ
);

-- 5. Pre-registrations Table (Firebase yapısıyla)
CREATE TABLE IF NOT EXISTS "preRegistrations" (
    id TEXT PRIMARY KEY,
    clubId TEXT,
    "Ad_Soyad" TEXT,
    "Resit_Olmayan_Adi_Soyadi" TEXT,
    "Telefon" TEXT,
    "Email" TEXT,
    "TC_No" TEXT,
    "Dogum_Tarihi" TIMESTAMPTZ,
    "Brans" TEXT,
    status TEXT DEFAULT 'pending',
    memberType TEXT,
    convertedToMember BOOLEAN DEFAULT false,
    convertedAt TIMESTAMPTZ,
    notes TEXT,
    tags JSONB DEFAULT '[]',
    createdAt TIMESTAMPTZ,
    updatedAt TIMESTAMPTZ
);

-- 6. Groups Table (Firebase yapısıyla)
CREATE TABLE IF NOT EXISTS groups (
    id TEXT PRIMARY KEY,
    clubId TEXT,
    name TEXT,
    branch TEXT,
    branchId TEXT,
    coach TEXT,
    ageGroup TEXT,
    capacity INTEGER,
    maxCapacity INTEGER,
    currentCount INTEGER DEFAULT 0,
    memberIds JSONB DEFAULT '[]',
    schedules JSONB DEFAULT '[]',
    scheduleDays JSONB DEFAULT '[]',
    scheduleTimes JSONB,
    court TEXT,
    isActive BOOLEAN DEFAULT true,
    createdAt TIMESTAMPTZ,
    updatedAt TIMESTAMPTZ
);

-- 7. Schedules Table (Firebase yapısıyla)
CREATE TABLE IF NOT EXISTS schedules (
    id TEXT PRIMARY KEY,
    clubId TEXT,
    memberId TEXT,
    groupId TEXT,
    branch TEXT,
    branchId TEXT,
    court TEXT,
    day TEXT,
    dayOfWeek TEXT,
    startTime TEXT,
    endTime TEXT,
    coach TEXT,
    duration INTEGER,
    isActive BOOLEAN DEFAULT true,
    notes TEXT,
    createdAt TIMESTAMPTZ,
    updatedAt TIMESTAMPTZ
);

-- 8. Attendance Records Table
CREATE TABLE IF NOT EXISTS attendanceRecords (
    id TEXT PRIMARY KEY,
    clubId TEXT,
    memberId TEXT,
    scheduleId TEXT,
    date DATE,
    status TEXT,
    notes TEXT,
    recordedBy TEXT,
    createdAt TIMESTAMPTZ
);

-- 9. CRM Leads Table (Firebase yapısıyla)
CREATE TABLE IF NOT EXISTS crmLeads (
    id TEXT PRIMARY KEY,
    clubId TEXT,
    fullName TEXT,
    phone TEXT,
    email TEXT,
    source TEXT,
    status TEXT DEFAULT 'new',
    branches JSONB DEFAULT '[]',
    notes TEXT,
    tags JSONB DEFAULT '[]',
    history JSONB DEFAULT '[]',
    lastContactDate TIMESTAMPTZ,
    nextFollowUpDate TIMESTAMPTZ,
    convertedToMemberId TEXT,
    convertedToMember BOOLEAN DEFAULT false,
    createdAt TIMESTAMPTZ,
    createdBy TEXT,
    updatedAt TIMESTAMPTZ,
    updatedBy TEXT
);

-- 10. CRM Tags Table
CREATE TABLE IF NOT EXISTS crmTags (
    id TEXT PRIMARY KEY,
    clubId TEXT,
    name TEXT,
    color TEXT,
    icon TEXT,
    category TEXT,
    isActive BOOLEAN DEFAULT true,
    createdAt TIMESTAMPTZ,
    updatedAt TIMESTAMPTZ
);

-- 11. WhatsApp Devices Table
CREATE TABLE IF NOT EXISTS whatsappDevices (
    id TEXT PRIMARY KEY,
    clubId TEXT,
    deviceName TEXT,
    instanceName TEXT,
    phoneNumber TEXT,
    apiKey TEXT,
    apiUrl TEXT,
    webhookUrl TEXT,
    isActive BOOLEAN DEFAULT true,
    isDefault BOOLEAN DEFAULT false,
    isConnected BOOLEAN DEFAULT false,
    lastConnected TIMESTAMPTZ,
    created_by TEXT,
    createdAt TIMESTAMPTZ,
    updatedAt TIMESTAMPTZ
);

-- 12. WhatsApp Incoming Calls Table
CREATE TABLE IF NOT EXISTS whatsappIncomingCalls (
    id TEXT PRIMARY KEY,
    clubId TEXT,
    phoneNumber TEXT,
    callerName TEXT,
    callTime TIMESTAMPTZ,
    duration INTEGER,
    isAnswered BOOLEAN DEFAULT false,
    isDeleted BOOLEAN DEFAULT false,
    isHidden BOOLEAN DEFAULT false,
    notes TEXT,
    convertedToLead BOOLEAN DEFAULT false,
    leadId TEXT,
    createdAt TIMESTAMPTZ
);

-- 13. WhatsApp Incoming Messages Table
CREATE TABLE IF NOT EXISTS whatsappIncomingMessages (
    id TEXT PRIMARY KEY,
    clubId TEXT,
    fromNumber TEXT,
    toNumber TEXT,
    messageText TEXT,
    messageType TEXT,
    mediaUrl TEXT,
    timestamp TIMESTAMPTZ,
    isRead BOOLEAN DEFAULT false,
    webhookData JSONB,
    createdAt TIMESTAMPTZ
);

-- 14. WhatsApp Messages Table (Outgoing)
CREATE TABLE IF NOT EXISTS whatsappMessages (
    id TEXT PRIMARY KEY,
    clubId TEXT,
    toNumber TEXT,
    messageText TEXT,
    deviceId TEXT,
    instanceName TEXT,
    status TEXT DEFAULT 'pending',
    sentAt TIMESTAMPTZ,
    deliveredAt TIMESTAMPTZ,
    error TEXT,
    errorMessage TEXT,
    createdAt TIMESTAMPTZ,
    updatedAt TIMESTAMPTZ
);

-- 15. Sent Messages Table
CREATE TABLE IF NOT EXISTS sentMessages (
    id TEXT PRIMARY KEY,
    clubId TEXT,
    recipientPhone TEXT,
    recipientName TEXT,
    messageText TEXT,
    messageType TEXT DEFAULT 'whatsapp',
    instanceName TEXT,
    deviceId TEXT,
    sentBy TEXT,
    sentAt TIMESTAMPTZ,
    status TEXT DEFAULT 'sent',
    createdAt TIMESTAMPTZ
);

-- 16. Message Queue Table
CREATE TABLE IF NOT EXISTS messageQueue (
    id TEXT PRIMARY KEY,
    clubId TEXT,
    toNumber TEXT,
    messageText TEXT,
    deviceId TEXT,
    instanceName TEXT,
    priority INTEGER DEFAULT 0,
    scheduledAt TIMESTAMPTZ,
    status TEXT DEFAULT 'pending',
    retryCount INTEGER DEFAULT 0,
    maxRetries INTEGER DEFAULT 3,
    error TEXT,
    errorMessage TEXT,
    sentAt TIMESTAMPTZ,
    createdAt TIMESTAMPTZ,
    updatedAt TIMESTAMPTZ
);

-- 17. Scheduled Messages Table
CREATE TABLE IF NOT EXISTS scheduledMessages (
    id TEXT PRIMARY KEY,
    clubId TEXT,
    recipientPhone TEXT,
    recipientName TEXT,
    messageText TEXT,
    scheduledFor TIMESTAMPTZ,
    device_id TEXT,
    status TEXT DEFAULT 'scheduled',
    sentAt TIMESTAMPTZ,
    createdBy TEXT,
    createdAt TIMESTAMPTZ,
    updatedAt TIMESTAMPTZ
);

-- 18. Campaigns Table
CREATE TABLE IF NOT EXISTS campaigns (
    id TEXT PRIMARY KEY,
    clubId TEXT,
    campaignName TEXT,
    messageText TEXT,
    targetAudience JSONB,
    recipientCount INTEGER DEFAULT 0,
    sentCount INTEGER DEFAULT 0,
    status TEXT DEFAULT 'draft',
    scheduledFor TIMESTAMPTZ,
    startedAt TIMESTAMPTZ,
    completedAt TIMESTAMPTZ,
    createdBy TEXT,
    createdAt TIMESTAMPTZ,
    updatedAt TIMESTAMPTZ
);

-- 19. Tasks Table
CREATE TABLE IF NOT EXISTS tasks (
    id TEXT PRIMARY KEY,
    clubId TEXT,
    title TEXT,
    description TEXT,
    messages TEXT,
    priority TEXT DEFAULT 'medium',
    status TEXT DEFAULT 'pending',
    assignedTo TEXT,
    dueDate TIMESTAMPTZ,
    completedAt TIMESTAMPTZ,
    createdBy TEXT,
    createdAt TIMESTAMPTZ,
    updatedAt TIMESTAMPTZ
);

-- 20. Expenses Table
CREATE TABLE IF NOT EXISTS expenses (
    id TEXT PRIMARY KEY,
    clubId TEXT,
    branch TEXT,
    category TEXT,
    description TEXT,
    amount DECIMAL(10,2),
    expenseDate DATE,
    paymentMethod TEXT,
    receiptUrl TEXT,
    recordedBy TEXT,
    createdAt TIMESTAMPTZ,
    updatedAt TIMESTAMPTZ
);

-- 21. Products Table
CREATE TABLE IF NOT EXISTS products (
    id TEXT PRIMARY KEY,
    clubId TEXT,
    branch TEXT,
    productName TEXT,
    category TEXT,
    price DECIMAL(10,2),
    stockQuantity INTEGER DEFAULT 0,
    description TEXT,
    isActive BOOLEAN DEFAULT true,
    createdAt TIMESTAMPTZ,
    updatedAt TIMESTAMPTZ
);

-- 22. Webhooks Table
CREATE TABLE IF NOT EXISTS webhooks (
    id TEXT PRIMARY KEY,
    clubId TEXT,
    webhookUrl TEXT,
    webhookType TEXT,
    active BOOLEAN DEFAULT true,
    isActive BOOLEAN DEFAULT true,
    lastTriggered TIMESTAMPTZ,
    createdAt TIMESTAMPTZ,
    updatedAt TIMESTAMPTZ
);

-- 23. User Activities Table
CREATE TABLE IF NOT EXISTS userActivities (
    id TEXT PRIMARY KEY,
    clubId TEXT,
    userId TEXT,
    activity TEXT,
    activityType TEXT,
    entityType TEXT,
    entityId TEXT,
    description TEXT,
    ipAddress TEXT,
    userAgent TEXT,
    createdAt TIMESTAMPTZ
);

-- 24. Holidays Table
CREATE TABLE IF NOT EXISTS holidays (
    id TEXT PRIMARY KEY,
    clubId TEXT,
    holidayName TEXT,
    startDate DATE,
    endDate DATE,
    description TEXT,
    createdAt TIMESTAMPTZ,
    updatedAt TIMESTAMPTZ
);

-- 25. Branches Table
CREATE TABLE IF NOT EXISTS branches (
    id TEXT PRIMARY KEY,
    clubId TEXT,
    branchName TEXT,
    branchId TEXT,
    icon TEXT,
    color TEXT,
    courts JSONB DEFAULT '[]',
    isActive BOOLEAN DEFAULT true,
    createdAt TIMESTAMPTZ,
    updatedAt TIMESTAMPTZ
);

-- Indexes for better performance
CREATE INDEX IF NOT EXISTS idx_members_clubId ON members(clubId);
CREATE INDEX IF NOT EXISTS idx_members_telefon ON members("Telefon");
CREATE INDEX IF NOT EXISTS idx_members_brans ON members("Brans");
CREATE INDEX IF NOT EXISTS idx_preRegistrations_clubId ON "preRegistrations"(clubId);
CREATE INDEX IF NOT EXISTS idx_schedules_clubId ON schedules(clubId);
CREATE INDEX IF NOT EXISTS idx_schedules_memberId ON schedules(memberId);
CREATE INDEX IF NOT EXISTS idx_crmLeads_clubId ON crmLeads(clubId);
CREATE INDEX IF NOT EXISTS idx_crmLeads_status ON crmLeads(status);
CREATE INDEX IF NOT EXISTS idx_crmLeads_phone ON crmLeads(phone);
CREATE INDEX IF NOT EXISTS idx_whatsappCalls_clubId ON whatsappIncomingCalls(clubId);
CREATE INDEX IF NOT EXISTS idx_whatsappCalls_phone ON whatsappIncomingCalls(phoneNumber);
CREATE INDEX IF NOT EXISTS idx_whatsappMessages_clubId ON whatsappMessages(clubId);
CREATE INDEX IF NOT EXISTS idx_messageQueue_status ON messageQueue(status);
CREATE INDEX IF NOT EXISTS idx_users_clubId ON users(clubId);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_groups_clubId ON groups(clubId);

-- RLS'i başlangıçta kapalı tut (daha sonra açılacak)
ALTER TABLE clubs DISABLE ROW LEVEL SECURITY;
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE members DISABLE ROW LEVEL SECURITY;
ALTER TABLE "preRegistrations" DISABLE ROW LEVEL SECURITY;
ALTER TABLE schedules DISABLE ROW LEVEL SECURITY;
ALTER TABLE groups DISABLE ROW LEVEL SECURITY;
ALTER TABLE crmLeads DISABLE ROW LEVEL SECURITY;
ALTER TABLE crmTags DISABLE ROW LEVEL SECURITY;
ALTER TABLE whatsappDevices DISABLE ROW LEVEL SECURITY;
ALTER TABLE whatsappIncomingCalls DISABLE ROW LEVEL SECURITY;
ALTER TABLE whatsappMessages DISABLE ROW LEVEL SECURITY;
ALTER TABLE sentMessages DISABLE ROW LEVEL SECURITY;
ALTER TABLE messageQueue DISABLE ROW LEVEL SECURITY;
ALTER TABLE scheduledMessages DISABLE ROW LEVEL SECURITY;
ALTER TABLE campaigns DISABLE ROW LEVEL SECURITY;
ALTER TABLE tasks DISABLE ROW LEVEL SECURITY;
ALTER TABLE expenses DISABLE ROW LEVEL SECURITY;
ALTER TABLE products DISABLE ROW LEVEL SECURITY;
ALTER TABLE webhooks DISABLE ROW LEVEL SECURITY;
ALTER TABLE userActivities DISABLE ROW LEVEL SECURITY;
ALTER TABLE settings DISABLE ROW LEVEL SECURITY;
ALTER TABLE branches DISABLE ROW LEVEL SECURITY;
ALTER TABLE holidays DISABLE ROW LEVEL SECURITY;
ALTER TABLE attendanceRecords DISABLE ROW LEVEL SECURITY;
ALTER TABLE whatsappIncomingMessages DISABLE ROW LEVEL SECURITY;

COMMENT ON TABLE clubs IS 'Kulüpler - Firebase uyumlu';
COMMENT ON TABLE members IS 'Üyeler - Türkçe field adlarıyla Firebase uyumlu';
COMMENT ON TABLE "preRegistrations" IS 'Ön kayıtlar - Firebase uyumlu';
COMMENT ON TABLE crmLeads IS 'CRM potansiyel müşteriler';

