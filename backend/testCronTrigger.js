/**
 * Manually trigger the cron job logic for testing
 */

require('dotenv').config();
const CheckIn = require('./models/checkinModel');
const Contact = require('./models/contactModel');
const Message = require('./models/messageModel');
const emailService = require('./services/emailService');

console.log('🔍 Checking for overdue check-ins...\n');

CheckIn.findOverdue((err, overdueCheckins) => {
    if (err) {
        console.error('❌ Error finding overdue check-ins:', err);
        process.exit(1);
    }

    if (!overdueCheckins || overdueCheckins.length === 0) {
        console.log('✓ No overdue check-ins found.');
        process.exit(0);
    }

    console.log(`✓ Found ${overdueCheckins.length} overdue check-in(s):\n`);

    overdueCheckins.forEach((checkin, index) => {
        console.log(`${index + 1}. User: ${checkin.user_email}`);
        console.log(`   Deadline: ${checkin.deadline}`);
        console.log(`   Notified: ${checkin.notified ? 'Yes' : 'No'}\n`);
    });

    // Process each overdue user
    let processed = 0;
    overdueCheckins.forEach(checkin => {
        const userId = checkin.user_id;
        const userEmail = checkin.user_email;

        Contact.findByUserId(userId, (err, contacts) => {
            if (err) {
                console.error(`❌ Error fetching contacts for ${userEmail}:`, err);
                return;
            }

            if (!contacts || contacts.length === 0) {
                console.log(`⚠️  No contacts found for ${userEmail}. Marking as notified.`);
                CheckIn.markNotified(userId, () => {
                    // Lock the user account even if no contacts
                    const { Pool } = require('pg');
                    const pool = new Pool({
                        connectionString: process.env.DATABASE_URL,
                        ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false
                    });

                    pool.query(
                        'UPDATE users SET is_locked = TRUE WHERE id = $1',
                        [userId]
                    ).then(() => {
                        console.log(`🔒 User ${userEmail} account locked (no contacts).\n`);
                        pool.end();
                    }).catch(lockErr => {
                        console.error(`❌ Error locking user ${userEmail}:`, lockErr);
                        pool.end();
                    });
                });
                return;
            }

            Message.findByUserId(userId, (err, messageTemplate) => {
                if (err) {
                    console.error(`❌ Error fetching message for ${userEmail}:`, err);
                    return;
                }

                const subject = messageTemplate?.subject || 'Emergency Alert from ShiMon';
                const body = messageTemplate?.body || 'This is an automated emergency message.';

                console.log(`📧 Sending emails for ${userEmail}...`);
                console.log(`   Subject: ${subject}`);
                console.log(`   Recipients: ${contacts.map(c => c.email).join(', ')}\n`);

                const emailPromises = contacts.map(contact => {
                    return emailService.sendEmail(
                        contact.email,
                        subject,
                        body,
                        `<p>${body.replace(/\n/g, '<br>')}</p>`
                    ).then(result => {
                        console.log(`   ✓ Email sent to ${contact.name} (${contact.email})`);
                        return result;
                    }).catch(error => {
                        console.error(`   ❌ Failed to send to ${contact.email}:`, error.message);
                    });
                });

                Promise.allSettled(emailPromises).then(() => {
                    CheckIn.markNotified(userId, (err) => {
                        if (err) {
                            console.error(`❌ Error marking ${userEmail} as notified:`, err);
                        } else {
                            console.log(`✅ User ${userEmail} marked as notified.\n`);

                            // Lock the user account
                            const { Pool } = require('pg');
                            const pool = new Pool({
                                connectionString: process.env.DATABASE_URL,
                                ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false
                            });

                            pool.query(
                                'UPDATE users SET is_locked = TRUE WHERE id = $1',
                                [userId]
                            ).then(() => {
                                console.log(`🔒 User ${userEmail} account locked.\n`);
                                pool.end();
                            }).catch(lockErr => {
                                console.error(`❌ Error locking user ${userEmail}:`, lockErr);
                                pool.end();
                            });
                        }

                        processed++;
                        if (processed === overdueCheckins.length) {
                            console.log('🎉 All overdue check-ins processed!');
                            setTimeout(() => process.exit(0), 1000); // Give time for lock query to complete
                        }
                    });
                });
            });
        });
    });
});
