const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false
});

async function simulateNearExpiry() {
    try {
        console.log('⏳ Setting time to 1 minute remaining...');
        const client = await pool.connect();

        // Target Production User ID
        const targetUserId = 'e6d22e4a-1c71-434a-b6c0-71b17fe7022a';
        console.log(`🎯 Targeting User: ${targetUserId}`);

        // 1. Unlock Account first
        await client.query('UPDATE users SET is_locked = FALSE WHERE id = $1', [targetUserId]);
        console.log('🔓 Account Unlocked');

        // 2. Set Deadline to NOW + 60 seconds
        const now = Date.now();
        const deadline = new Date(now + 60 * 1000); // +1 minute
        const checkedAt = new Date(now + 60 * 1000 - 48 * 60 * 60 * 1000); // 48h before deadline

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
        // Note: is_locked is not in checkins table, it's in users. We handled it above.

        const res = await client.query(query, [targetUserId, checkedAt, deadline]);
        console.log('✅ Simulation Setup Complete!');
        console.log(`⏰ New Deadline: ${res.rows[0].deadline}`);
        console.log('📱 App should show ~1 minute remaining.');

        client.release();
        pool.end();

    } catch (err) {
        console.error('❌ Error:', err);
        pool.end();
    }
}

simulateNearExpiry();
