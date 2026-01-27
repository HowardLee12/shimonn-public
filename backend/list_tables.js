const { Pool } = require('pg');
require('dotenv').config(); // Load .env from CWD

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false
});

async function listTables() {
    try {
        if (!process.env.DATABASE_URL) {
            throw new Error('DATABASE_URL is not defined');
        }
        console.log('🔌 Connecting to:', process.env.DATABASE_URL.split('@')[1]);
        const client = await pool.connect();

        const res = await client.query(`
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public'
            ORDER BY table_name;
        `);

        console.log('📋 Tables found:', res.rows.map(r => r.table_name));

        client.release();
    } catch (err) {
        console.error('❌ Error:', err);
    } finally {
        await pool.end();
    }
}

listTables();
