const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false
});

async function findUser() {
    try {
        const targetDeviceID = '4983D6B9';
        console.log(`🔍 Searching for User with Device ID containing: ${targetDeviceID}...`);

        const client = await pool.connect();

        // Use ILIKE in case of case sensitivity or if the ID in the UI is just a prefix/substring
        const query = `SELECT * FROM users WHERE "device_id" ILIKE $1`;
        const res = await client.query(query, [`%${targetDeviceID}%`]);

        if (res.rows.length === 0) {
            console.log('❌ No user found matching that Device ID.');
            console.log('Dumping ALL users to check format:');
            const allUsers = await client.query('SELECT * FROM users');
            console.log(JSON.stringify(allUsers.rows, null, 2));
        } else {
            console.log('✅ User Found!');
            console.log(JSON.stringify(res.rows[0], null, 2));
            console.log(`👉 USER_ID: ${res.rows[0].id}`);
        }

        client.release();
    } catch (err) {
        console.error('❌ Error:', err);
    } finally {
        await pool.end();
    }
}

findUser();
