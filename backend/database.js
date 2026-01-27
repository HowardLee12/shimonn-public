const { Pool } = require('pg');
require('dotenv').config();

// PostgreSQL connection configuration
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.DB_SSL === 'true' ? {
        rejectUnauthorized: false
    } : false
});

// Test connection
pool.on('connect', () => {
    console.log('✅ Connected to PostgreSQL database');
});

pool.on('error', (err) => {
    console.error('❌ Unexpected error on idle PostgreSQL client', err);
    process.exit(-1);
});

// Test initial connection
pool.query('SELECT NOW()', (err, res) => {
    if (err) {
        console.error('❌ Could not connect to PostgreSQL database:', err.message);
        console.error('Please check your DATABASE_URL in .env file');
    } else {
        console.log('✅ PostgreSQL connection test successful:', res.rows[0].now);
    }
});

module.exports = pool;

