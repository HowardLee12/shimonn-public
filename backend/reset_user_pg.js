const { Pool } = require('pg');

const pool = new Pool({
    connectionString: 'postgresql://localhost:5432/shimon_test',
    ssl: false
});

const USER_ID = '316a930b-9336-4a6d-8093-fa2f2d905959';

async function resetUser() {
    try {
        console.log(`Resetting user ${USER_ID}...`);

        await pool.query('BEGIN');

        // 1. Delete Contacts
        const resContacts = await pool.query('DELETE FROM contacts WHERE user_id = $1', [USER_ID]);
        console.log(`Deleted ${resContacts.rowCount} contacts.`);

        // 2. Delete Checkins
        const resCheckins = await pool.query('DELETE FROM checkins WHERE user_id = $1', [USER_ID]);
        console.log(`Deleted ${resCheckins.rowCount} checkins.`);

        // 3. Delete User
        const resUser = await pool.query('DELETE FROM users WHERE id = $1', [USER_ID]);
        console.log(`Deleted ${resUser.rowCount} user.`);

        await pool.query('COMMIT');
        console.log("✅ User reset successfully.");
    } catch (err) {
        await pool.query('ROLLBACK');
        console.error("Error resetting user:", err);
    } finally {
        await pool.end();
    }
}

resetUser();
