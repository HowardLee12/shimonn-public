const { Pool } = require('pg');
const emailService = require('./services/emailService');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false
});

async function sendManualEmail() {
    try {
        console.log('🔍 Looking for contact Krystal...');

        // Find Krystal via email to be precise
        const res = await pool.query(
            "SELECT * FROM contacts WHERE email = $1",
            ['krystaljadephang@gmail.com']
        );

        if (res.rows.length === 0) {
            console.error('❌ Contact Krystal not found in database!');
            return;
        }

        const contact = res.rows[0];
        console.log(`✅ Found contact: ${contact.name}`);

        const subject = contact.custom_subject || '【緊急】來自 死了嗎 (Shimonn) 的重要通知';
        const body = contact.custom_body || 'This is an automated emergency message.';

        console.log(`📧 Sending email to ${contact.email}...`);
        console.log(`   Subject: ${subject}`);

        await emailService.sendEmail(
            contact.email,
            subject,
            body,
            `<p>${body.replace(/\n/g, '<br>')}</p>`
        );

        console.log('✅ Email sent successfully!');

    } catch (err) {
        console.error('❌ Error sending email:', err);
    } finally {
        pool.end();
    }
}

sendManualEmail();
