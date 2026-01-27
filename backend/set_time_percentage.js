const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false
});

async function setTimePercentage(percentage) {
    try {
        const targetUserId = 'e6d22e4a-1c71-434a-b6c0-71b17fe7022a';
        console.log(`🎨 Setting time to ${percentage * 100}% remaining for User: ${targetUserId}`);

        const client = await pool.connect();

        // Calculate deadline based on percentage
        // Total time = 48 hours = 172800 seconds
        const totalSeconds = 48 * 3600;
        const remainingSeconds = totalSeconds * percentage;

        const now = new Date();
        const deadline = new Date(now.getTime() + remainingSeconds * 1000);
        const checkedAt = new Date(now.getTime() - (totalSeconds - remainingSeconds) * 1000);

        const query = `
            UPDATE checkins 
            SET deadline = $1, 
                checked_at = $2,
                notified = FALSE,
                updated_at = NOW()
            WHERE user_id = $3
            RETURNING *;
        `;

        const res = await client.query(query, [deadline, checkedAt, targetUserId]);

        if (res.rows.length > 0) {
            console.log('✅ Time Percentage Set!');
            console.log(`Remaining: ${Math.floor(remainingSeconds / 3600)}h ${Math.floor((remainingSeconds % 3600) / 60)}m`);
            console.log('Record:', JSON.stringify(res.rows[0], null, 2));
        } else {
            console.log('❌ No record found to update');
        }

        client.release();
    } catch (err) {
        console.error('❌ Error:', err);
    } finally {
        await pool.end();
    }
}

// Get percentage from command line argument, default to 0.3 (30%)
const percentage = parseFloat(process.argv[2]) || 0.3;
setTimePercentage(percentage);
