/**
 * Migration script to add 'notified' column to existing checkins table
 */

const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const dbPath = path.resolve(__dirname, 'deadmansswitch.sqlite');
const db = new sqlite3.Database(dbPath);

console.log('Running database migration...\n');

db.serialize(() => {
    // Check if column already exists
    db.all(`PRAGMA table_info(checkins)`, (err, columns) => {
        if (err) {
            console.error('Error checking table schema:', err);
            process.exit(1);
        }

        const hasNotifiedColumn = columns.some(col => col.name === 'notified');

        if (hasNotifiedColumn) {
            console.log('✓ Column "notified" already exists. No migration needed.');
            db.close();
            process.exit(0);
        } else {
            console.log('Adding "notified" column to checkins table...');
            db.run(`ALTER TABLE checkins ADD COLUMN notified BOOLEAN DEFAULT 0`, (err) => {
                if (err) {
                    console.error('❌ Migration failed:', err);
                    process.exit(1);
                } else {
                    console.log('✅ Migration successful! Column "notified" added.');
                    db.close();
                    process.exit(0);
                }
            });
        }
    });
});
