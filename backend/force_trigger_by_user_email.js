const { Pool } = require('pg');
const emailService = require('./services/emailService');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false
});

const targetUserId = process.argv[2];

if (!targetUserId) {
    console.error('Please provide USER ID as argument');
    process.exit(1);
}

async function trigger() {
    try {
        console.log(`🔍 Triggering for User ID: ${targetUserId}`);

        // Fetch contacts
        const contactRes = await pool.query('SELECT * FROM contacts WHERE user_id = $1', [targetUserId]);

        if (contactRes.rows.length === 0) {
            console.log('⚠️ No contacts found for this user.');
            return;
        }

        console.log(`✅ Found ${contactRes.rows.length} contacts.`);

        // Fetch message template
        const msgRes = await pool.query('SELECT * FROM messages WHERE user_id = $1', [targetUserId]);
        const template = msgRes.rows[0];

        const defaultSubject = template?.subject || '【緊急】來自 死了嗎 (Shimonn) 的重要通知';
        const defaultBody = template?.body || '這是一封自動發送的緊急訊息。用戶未在預定時間內回報平安，系統判定可能發生緊急狀況，特此通知您。';

        for (const contact of contactRes.rows) {
            const subject = contact.custom_subject || defaultSubject;
            const body = contact.custom_body || defaultBody;

            console.log(`📧 Sending to ${contact.name} <${contact.email}>`);
            console.log(`   Subject: ${subject}`);

            try {
                await emailService.sendEmail(
                    contact.email,
                    subject,
                    body,
                    `<p>${body.replace(/\n/g, '<br>')}</p>`
                );
                console.log('   ✅ Sent');
            } catch (e) {
                console.error('   ❌ Failed:', e.message);
            }
        }

    } catch (err) {
        console.error('Error:', err);
    } finally {
        pool.end();
    }
}

trigger();
