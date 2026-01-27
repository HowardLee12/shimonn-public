const { Resend } = require('resend');

const resend = new Resend(process.env.RESEND_API_KEY);

/**
 * Sends an email using Resend
 * @param {string} to - Recipient email address
 * @param {string} subject - Email subject
 * @param {string} text - Email body text
 * @param {string} [html] - Optional HTML body
 * @returns {Promise<Object>} - Resend API response
 */
const sendEmail = async (to, subject, text, html) => {
    if (!process.env.RESEND_API_KEY) {
        console.warn('RESEND_API_KEY is not set. Email sending skipped.');
        return { id: 'mock-id', warning: 'No API Key' };
    }

    try {
        const envFrom = process.env.EMAIL_FROM_ADDRESS || 'onboarding@resend.dev';
        // Add Display Name "死了嗎？"
        const fromAddress = `死了嗎？ <${envFrom}>`;

        const data = await resend.emails.send({
            from: fromAddress,
            to: to,
            subject: subject,
            text: text,
            html: html,
        });
        return data;
    } catch (error) {
        console.error('Error sending email:', error);
        throw error;
    }
};

module.exports = {
    sendEmail
};
