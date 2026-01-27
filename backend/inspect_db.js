const { Pool } = require('pg');
// Don't use dotenv here, rely on container env vars to ensure we see what the app sees
// require('dotenv').config(); 

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false
});

async function inspect() {
    try {
        console.log('🔍 Inspecting Database...');
        if (!process.env.DATABASE_URL) {
            console.log('❌ DATABASE_URL is undefined in this environment!');
            process.exit(1);
        }
        // Log partial URL for verification
        const parts = process.env.DATABASE_URL.split('@');
        console.log('DB Connection:', parts.length > 1 ? parts[1] : 'Invalid URL Format');

        const client = await pool.connect();

        const users = await client.query('SELECT * FROM users');
        console.log(`bustUsers count: ${users.rows.length}`);
        if (users.rows.length > 0) {
            console.log('Latest User ID:', users.rows[users.rows.length - 1].id);
        }

        const checkins = await client.query('SELECT * FROM checkins');
        console.log(`Checkins count: ${checkins.rows.length}`);

        if (checkins.rows.length > 0) {
            console.log('Latest Checkin:', JSON.stringify(checkins.rows[checkins.rows.length - 1], null, 2));
        } else {
            console.log('⚠️ No checkins found!');
        }

        client.release();
    } catch (err) {
        console.error('❌ Error:', err);
    } finally {
        await pool.end();
    }
}
inspect();
