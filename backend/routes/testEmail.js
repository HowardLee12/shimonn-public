const express = require('express');
const router = express.Router();
const emailService = require('../services/emailService');

// POST /api/test-email
router.post('/', async (req, res) => {
    const { to, subject, text, html } = req.body;

    if (!to || !subject || !text) {
        return res.status(400).json({ error: 'Missing required fields: to, subject, text' });
    }

    try {
        const result = await emailService.sendEmail(to, subject, text, html);
        res.status(200).json({ message: 'Email sent successfully', data: result });
    } catch (error) {
        res.status(500).json({ error: 'Failed to send email', details: error.message });
    }
});

module.exports = router;
