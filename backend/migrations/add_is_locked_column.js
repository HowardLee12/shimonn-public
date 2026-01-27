const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false
});

async function addIsLockedColumn() {
    try {
        console.log('🔌 Connecting to database...');
        const client = await pool.connect();

        // Check if column already exists
        console.log('🔍 Checking if is_locked column exists...');
        const checkColumn = await client.query(`
            SELECT column_name 
            FROM information_schema.columns 
            WHERE table_name = 'users' 
            AND column_name = 'is_locked';
        `);

        if (checkColumn.rows.length > 0) {
            console.log('✅ Column "is_locked" already exists. Skipping.');
            client.release();
            return;
        }

        // Add is_locked column
        console.log('➕ Adding "is_locked" column to users table...');
        await client.query(`
            ALTER TABLE users 
            ADD COLUMN is_locked BOOLEAN DEFAULT FALSE;
        `);

        console.log('✅ Migration successful: "is_locked" column added.');
        client.release();
    } catch (err) {
        console.error('❌ Migration failed:', err);
        throw err;
    } finally {
        await pool.end();
    }
}

addIsLockedColumn();
