const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false
});

async function simulateTimeout() {
    try {
        console.log('⚰️  Simulating Death (Timeout)...');
        if (!process.env.DATABASE_URL) {
            console.error('❌ DATABASE_URL is missing!');
            process.exit(1);
        }

        const client = await pool.connect();

        // Update ALL checkins to be overdue (deadline = 1 hour ago)
        // and reset notified status so the cron job picks it up
        const res = await client.query(`
            UPDATE checkins 
            SET deadline = NOW() - INTERVAL '1 hour', notified = FALSE
            RETURNING *;
        `);

        console.log(`✅ Updated ${res.rowCount} records to be OVERDUE.`);
        console.log('✅ Deadline set to 1 hour ago.');
        console.log('⏳ The next Cron job (runs every minute) should pick this up and send emails.');

        client.release();
    } catch (err) {
        console.error('❌ Simulation failed:', err);
    } finally {
        await pool.end();
    }
}

simulateTimeout();
