const db = require('../database');
const { sendEmergencyEmail } = require('./emailService');

const checkDeadlines = () => {
    console.log('Checking for expired deadlines...');
    const now = new Date().toISOString();

    // Find checkins where deadline < now AND status is not 'alerted' (need to add status column)
    db.all(`SELECT * FROM checkins WHERE deadline < ?`, [now], (err, rows) => {
        if (err) {
            console.error(err);
            return;
        }

        rows.forEach(row => {
            console.log(`User ${row.user_id} missed deadline! Triggering protocol.`);

            // Logic:
            // 1. Fetch user's emergency contacts
            // 2. Fetch user's emergency message
            // 3. Send email to contacts
            // 4. Mark this checkin event as 'fired' to avoid re-sending
        });
    });
};

// Run every hour
// setInterval(checkDeadlines, 3600 * 1000);

module.exports = { checkDeadlines };
