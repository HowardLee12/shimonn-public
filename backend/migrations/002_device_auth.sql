-- Migration: Add device-based authentication
-- Remove email/password, add device_id

-- Step 1: Add new columns (nullable first to allow existing data)
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS device_id VARCHAR(255),
ADD COLUMN IF NOT EXISTS device_type VARCHAR(50),
ADD COLUMN IF NOT EXISTS last_device_sync TIMESTAMPTZ;

-- Step 2: Generate device IDs for existing users (if any)
UPDATE users 
SET device_id = gen_random_uuid()::text 
WHERE device_id IS NULL;

-- Step 3: Make device_id NOT NULL and UNIQUE
ALTER TABLE users 
ALTER COLUMN device_id SET NOT NULL,
ADD CONSTRAINT unique_device_id UNIQUE (device_id);

-- Step 4: Remove old authentication columns
ALTER TABLE users 
DROP COLUMN IF EXISTS email,
DROP COLUMN IF EXISTS password;

-- Step 5: Create index for fast device_id lookups
CREATE INDEX IF NOT EXISTS idx_users_device_id ON users(device_id);

-- Verify migration
COMMENT ON COLUMN users.device_id IS 'Unique device identifier (iCloud ID or Keychain UUID)';
COMMENT ON COLUMN users.device_type IS 'Device type (iOS, Android, etc.)';
COMMENT ON COLUMN users.last_device_sync IS 'Last time device synced with backend';
