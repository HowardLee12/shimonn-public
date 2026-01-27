-- ShiMon PostgreSQL Database Schema
-- Dead Man's Switch Application
-- PostgreSQL 15+

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================
-- Table: users
-- ============================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);

COMMENT ON TABLE users IS 'User accounts for the Dead Man''s Switch application';
COMMENT ON COLUMN users.email IS 'User email address (unique identifier for login)';
COMMENT ON COLUMN users.password IS 'Bcrypt hashed password';

-- ============================================
-- Table: checkins
-- ============================================
CREATE TABLE checkins (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    checked_at TIMESTAMPTZ NOT NULL,
    deadline TIMESTAMPTZ NOT NULL,
    notified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_user_checkin UNIQUE(user_id)
);

CREATE INDEX idx_checkins_user_id ON checkins(user_id);
CREATE INDEX idx_checkins_deadline ON checkins(deadline);
CREATE INDEX idx_checkins_notified ON checkins(notified);
CREATE INDEX idx_checkins_overdue ON checkins(deadline, notified) WHERE notified = FALSE;

COMMENT ON TABLE checkins IS 'User check-in records with 48-hour countdown';
COMMENT ON COLUMN checkins.checked_at IS 'Timestamp of last check-in';
COMMENT ON COLUMN checkins.deadline IS 'Deadline (48 hours from last check-in)';
COMMENT ON COLUMN checkins.notified IS 'Whether emergency contacts have been notified';

-- ============================================
-- Table: contacts
-- ============================================
CREATE TABLE contacts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    contact_order INTEGER NOT NULL DEFAULT 0,
    custom_subject TEXT,
    custom_body TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_contact_order CHECK (contact_order >= 0)
);

CREATE INDEX idx_contacts_user_id ON contacts(user_id);
CREATE INDEX idx_contacts_order ON contacts(user_id, contact_order);

COMMENT ON TABLE contacts IS 'Emergency contacts for each user';
COMMENT ON COLUMN contacts.contact_order IS 'Display order (0-indexed)';
COMMENT ON COLUMN contacts.custom_subject IS 'Custom email subject for this contact (optional)';
COMMENT ON COLUMN contacts.custom_body IS 'Custom email body for this contact (optional)';

-- ============================================
-- Table: messages
-- ============================================
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    subject TEXT NOT NULL,
    body TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_user_message UNIQUE(user_id)
);

CREATE INDEX idx_messages_user_id ON messages(user_id);

COMMENT ON TABLE messages IS 'Default emergency message template for each user';
COMMENT ON COLUMN messages.subject IS 'Default email subject';
COMMENT ON COLUMN messages.body IS 'Default email body';

-- ============================================
-- Trigger: Update updated_at timestamp
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_checkins_updated_at BEFORE UPDATE ON checkins
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_contacts_updated_at BEFORE UPDATE ON contacts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_messages_updated_at BEFORE UPDATE ON messages
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
