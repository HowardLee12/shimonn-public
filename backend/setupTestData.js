/**
 * Test script to verify automated emergency email system
 * This creates a test user with an overdue check-in and verifies emails are sent
 */

const db = require('./database');
const { v4: uuidv4 } = require('uuid');
const bcrypt = require('bcryptjs');

// Test data
const testUserId = uuidv4();
const testEmail = 'test-user@example.com';
const testPassword = bcrypt.hashSync('password123', 8);

// Create test user
db.run(
    `INSERT INTO users (id, email, password) VALUES (?, ?, ?)`,
    [testUserId, testEmail, testPassword],
    (err) => {
        if (err) {
            console.error('Error creating test user:', err);
            return;
        }
        console.log('✓ Test user created:', testEmail);

        // Create overdue check-in (deadline 1 hour ago)
        const overdueDeadline = new Date(Date.now() - 60 * 60 * 1000).toISOString();
        const checkinId = uuidv4();

        db.run(
            `INSERT INTO checkins (id, user_id, checked_at, deadline, notified) VALUES (?, ?, ?, ?, 0)`,
            [checkinId, testUserId, new Date().toISOString(), overdueDeadline],
            (err) => {
                if (err) {
                    console.error('Error creating overdue check-in:', err);
                    return;
                }
                console.log('✓ Overdue check-in created (deadline was 1 hour ago)');

                // Create emergency contacts
                const contact1Id = uuidv4();
                const contact2Id = uuidv4();

                db.run(
                    `INSERT INTO contacts (id, user_id, name, email, contact_order) VALUES (?, ?, ?, ?, ?)`,
                    [contact1Id, testUserId, 'Emergency Contact 1', 'wei00925@gmail.com', 1],
                    (err) => {
                        if (err) {
                            console.error('Error creating contact 1:', err);
                            return;
                        }
                        console.log('✓ Contact 1 created: wei00925@gmail.com');

                        // Create emergency message template
                        const messageId = uuidv4();
                        db.run(
                            `INSERT INTO messages (id, user_id, subject, body) VALUES (?, ?, ?, ?)`,
                            [
                                messageId,
                                testUserId,
                                '🚨 Emergency Alert - User Has Not Checked In',
                                'This is an automated emergency message from ShiMon.\n\nThe user has not checked in within the expected 48-hour timeframe. Please check on their well-being.\n\nThis message was automatically sent by the Dead Man\'s Switch system.'
                            ],
                            (err) => {
                                if (err) {
                                    console.error('Error creating message template:', err);
                                    return;
                                }
                                console.log('✓ Emergency message template created');
                                console.log('\n✅ Test data setup complete!');
                                console.log('\nTo trigger the cron job manually, run:');
                                console.log('  node testCronTrigger.js');
                                console.log('\nOr wait for the next hourly cron run.');

                                process.exit(0);
                            }
                        );
                    }
                );
            }
        );
    }
);
