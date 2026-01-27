const cron = require('node-cron');
const CheckIn = require('../models/checkinModel');
const Contact = require('../models/contactModel');
const Message = require('../models/messageModel');
const emailService = require('./emailService');

/**
 * Cron job that runs every hour to check for overdue check-ins
 * and send emergency emails to configured contacts
 */
const startCronJob = () => {
    // Run every minute
    // Format: minute hour day month weekday
    // '* * * * *' means "at every minute"
    cron.schedule('* * * * *', async () => {
        console.log('[CRON] Running overdue check-in scan...');

        CheckIn.findOverdue((err, overdueCheckins) => {
            if (err) {
                console.error('[CRON] Error finding overdue check-ins:', err);
                return;
            }

            if (!overdueCheckins || overdueCheckins.length === 0) {
                console.log('[CRON] No overdue check-ins found.');
                return;
            }

            console.log(`[CRON] Found ${overdueCheckins.length} overdue check-in(s). Processing...`);

            // Process each overdue user
            overdueCheckins.forEach(checkin => {
                processOverdueUser(checkin);
            });
        });
    });

    console.log('[CRON] Monitoring service started. Checking for overdue check-ins every hour.');
};

/**
 * Process a single overdue user: fetch contacts, message template, and send emails
 */
const processOverdueUser = (checkin) => {
    const userId = checkin.user_id;
    const userEmail = checkin.user_email;

    console.log(`[CRON] Processing overdue user: ${userEmail} (ID: ${userId})`);

    // Fetch user's emergency contacts
    Contact.findByUserId(userId, (err, contacts) => {
        if (err) {
            console.error(`[CRON] Error fetching contacts for user ${userId}:`, err);
            return;
        }

        if (!contacts || contacts.length === 0) {
            console.log(`[CRON] No contacts found for user ${userId}. Skipping.`);
            CheckIn.markNotified(userId, () => { });
            return;
        }

        // Fetch user's emergency message template
        Message.findByUserId(userId, (err, messageTemplate) => {
            if (err) {
                console.error(`[CRON] Error fetching message template for user ${userId}:`, err);
                return;
            }

            const defaultSubject = messageTemplate?.subject || '【緊急】來自 死了嗎 (Shimonn) 的重要通知';
            const defaultBody = messageTemplate?.body || '這是一封自動發送的緊急訊息。用戶未在預定時間內回報平安，系統判定可能發生緊急狀況，特此通知您。';

            // Send email to each contact
            const emailPromises = contacts.map(contact => {
                const finalSubject = contact.custom_subject || defaultSubject;
                const finalBody = contact.custom_body || defaultBody;

                return emailService.sendEmail(
                    contact.email,
                    finalSubject,
                    finalBody,
                    `<p>${finalBody.replace(/\n/g, '<br>')}</p>`
                ).then(result => {
                    console.log(`[CRON] Email sent to ${contact.name} (${contact.email})`);
                    return result;
                }).catch(error => {
                    console.error(`[CRON] Failed to send email to ${contact.email}:`, error);
                });
            });


            // After all emails are sent (or attempted), mark as notified AND lock account
            Promise.allSettled(emailPromises).then(() => {
                CheckIn.markNotified(userId, (err, changes) => {
                    if (err) {
                        console.error(`[CRON] Error marking user ${userId} as notified:`, err);
                    } else {
                        console.log(`[CRON] User ${userId} marked as notified. Emergency emails sent to ${contacts.length} contact(s).`);

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
                            console.log(`[CRON] User ${userId} account locked.`);
                            pool.end();
                        }).catch(lockErr => {
                            console.error(`[CRON] Error locking user ${userId}:`, lockErr);
                            pool.end();
                        });
                    }
                });
            });

        });
    });
};

module.exports = {
    startCronJob
};
