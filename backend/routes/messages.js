const express = require('express');
const router = express.Router();
const verifyToken = require('../middleware/authMiddleware');
const Message = require('../models/messageModel');
const User = require('../models/userModel');
const emailService = require('../services/emailService');

router.use(verifyToken);

// GET user's emergency message template
router.get('/', (req, res) => {
    Message.findByUserId(req.userId, (err, message) => {
        if (err) return res.status(500).send("Error fetching message template.");
        res.status(200).send(message || { subject: '', body: '' });
    });
});

// POST/PUT - Create or update emergency message template
router.post('/', (req, res) => {
    const { subject, body } = req.body;

    if (!subject || !body) {
        return res.status(400).send("Subject and body are required.");
    }

    Message.createOrUpdate(req.userId, subject, body, (err, result) => {
        if (err) return res.status(500).send("Error saving message template.");
        res.status(200).send(result);
    });
});

// POST - Send test email to user's own email
router.post('/test', async (req, res) => {
    try {
        // Get user's email
        User.findById(req.userId, async (err, user) => {
            if (err || !user) {
                return res.status(404).send("User not found.");
            }

            // Get user's message template
            Message.findByUserId(req.userId, async (err, messageTemplate) => {
                if (err) {
                    return res.status(500).send("Error fetching message template.");
                }

                const subject = messageTemplate?.subject || '【緊急】未報平安通知';
                const body = messageTemplate?.body || 'This is an automated message. I have not checked in to my Dead Man\'s Switch service for 48 hours. Please check on me.';

                try {
                    // Send test email to user's own email
                    const result = await emailService.sendEmail(
                        user.email,
                        `[TEST] ${subject}`,
                        `This is a TEST email preview.\n\n${body}`,
                        `<div style="padding: 20px; background-color: #fff3cd; border: 1px solid #ffc107; border-radius: 5px; margin-bottom: 20px;">
                            <strong>⚠️ This is a TEST email preview</strong>
                            <p>Your emergency contacts will receive the message below (without this yellow box).</p>
                        </div>
                        <div style="padding: 20px; background-color: #f8f9fa; border-radius: 5px;">
                            <p style="white-space: pre-wrap;">${body.replace(/\n/g, '<br>')}</p>
                        </div>`
                    );

                    res.status(200).json({
                        message: 'Test email sent successfully',
                        sentTo: user.email,
                        data: result
                    });
                } catch (emailError) {
                    console.error('Error sending test email:', emailError);
                    res.status(500).send("Failed to send test email.");
                }
            });
        });
    } catch (error) {
        console.error('Error in test email endpoint:', error);
        res.status(500).send("Internal server error.");
    }
});

module.exports = router;
