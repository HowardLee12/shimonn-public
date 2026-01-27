const { Pool } = require('pg');
require('dotenv').config(); // Load .env from CWD (which will be backend/)

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false
});

async function migrate() {
    try {
        console.log('🔌 Connecting to database...');
        const client = await pool.connect();

        console.log('🔍 Checking if streak_days column exists...');
        const res = await client.query(`
            SELECT column_name 
            FROM information_schema.columns 
            WHERE table_name='checkins' AND column_name='streak_days';
        `);

        if (res.rows.length > 0) {
            console.log('✅ Column "streak_days" already exists. Skipping.');
        } else {
            console.log('➕ Adding "streak_days" column...');
            await client.query(`
                ALTER TABLE checkins 
                ADD COLUMN streak_days INTEGER DEFAULT 0;
            `);
            console.log('✅ Migration successful: "streak_days" column added.');
        }

        client.release();
    } catch (err) {
        console.error('❌ Migration failed:', err);
        process.exit(1);
    } finally {
        await pool.end();
    }
}

migrate();
