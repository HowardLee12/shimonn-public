const { Pool } = require('pg');

const pool = new Pool({
    connectionString: 'postgresql://localhost:5432/shimon_test',
    ssl: false
});

async function listUsers() {
    try {
        const res = await pool.query('SELECT * FROM users');
        console.log("Users in Postgres:", res.rows);
    } catch (err) {
        console.error("Error query:", err);
    } finally {
        await pool.end();
    }
}

listUsers();
