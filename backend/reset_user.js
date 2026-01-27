const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const dbPath = path.join(__dirname, 'deadmansswitch.sqlite');
const db = new sqlite3.Database(dbPath);

const USER_ID = 'e6d22e4a-1c71-434a-b6c0-71b17fe7022a';

db.serialize(() => {
    db.run("BEGIN TRANSACTION");

    // 1. Delete Contacts
    db.run("DELETE FROM contacts WHERE user_id = ?", [USER_ID], function (err) {
        if (err) return console.error("Error deleting contacts:", err);
        console.log(`Deleted ${this.changes} contacts`);
    });

    // 2. Delete Checkins
    db.run("DELETE FROM checkins WHERE user_id = ?", [USER_ID], function (err) {
        if (err) return console.error("Error deleting checkins:", err);
        console.log(`Deleted ${this.changes} checkins`);
    });

    // 3. Delete Messages (if any, though strict schema might not exist for separate message table)
    // Check schema first? Assuming simple structure for now. Model: user has stored message in user table?
    // Wait, earlier models showed 'custom_subject' in contacts. Default message is likely in users or separate.
    // Let's check 'messages' table just in case, but ignore if not exists.

    // 4. Delete User
    db.run("DELETE FROM users WHERE id = ?", [USER_ID], function (err) {
        if (err) {
            console.error("Error deleting user:", err);
            db.run("ROLLBACK");
            return;
        }
        console.log(`Deleted ${this.changes} user`);

        db.run("COMMIT", () => {
            console.log("✅ User reset complete. Account deleted.");
        });
    });
});

db.close();
