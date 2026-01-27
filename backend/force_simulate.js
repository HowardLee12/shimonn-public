const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false
});

async function forceSimulate() {
    try {
        console.log('Force Simulating Timeout for Latest User...');
        const client = await pool.connect();

        // 1. Target specific user (Production ID)
        const targetUserId = 'e6d22e4a-1c71-434a-b6c0-71b17fe7022a';
        console.log(`🎯 Targeting User: ${targetUserId}`);

        // 2. Upsert Check-in to be overdue
        // We set deadline to 1 hour ago
        const deadline = new Date(Date.now() - 60 * 60 * 1000);
        const checkedAt = new Date(Date.now() - 49 * 60 * 60 * 1000); // Checked 49 hours ago

        const query = `
            INSERT INTO checkins (user_id, checked_at, deadline, notified, streak_days)
            VALUES ($1, $2, $3, FALSE, 1)
            ON CONFLICT (user_id) 
            DO UPDATE SET 
                deadline = $3, 
                checked_at = $2,
                notified = FALSE,
                streak_days = 1
            RETURNING *;
        `;

        const res = await client.query(query, [targetUserId, checkedAt, deadline]);
        console.log('✅ Force Simulation Complete!');
        console.log('Record:', JSON.stringify(res.rows[0], null, 2));
        console.log('⏳ Usage: The App should now show "00:00:00" and Red color (after a refresh/pull).');
        console.log('⏳ Cron Job will send email in < 1 minute.');

        client.release();
    } catch (err) {
        console.error('❌ Error:', err);
    } finally {
        await pool.end();
    }
}

forceSimulate();
