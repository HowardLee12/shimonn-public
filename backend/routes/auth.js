const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const User = require('../models/userModel');

const SECRET_KEY = process.env.JWT_SECRET || 'supersecretkey';

// Device-based authentication (auto register/login)
router.post('/device', (req, res) => {
    const { deviceID, deviceType } = req.body;

    if (!deviceID) {
        return res.status(400).json({ error: 'Device ID is required' });
    }

    User.findOrCreateByDeviceID(deviceID, deviceType || 'iOS', (err, user) => {
        if (err) {
            console.error('Device auth error:', err);
            return res.status(500).json({ error: 'Authentication failed', details: err.message });
        }

        const token = jwt.sign({ id: user.id }, SECRET_KEY, { expiresIn: '30d' });
        res.status(200).json({
            auth: true,
            token: token,
            user: {
                id: user.id,
                deviceID: user.device_id,
                deviceType: user.device_type,
                createdAt: user.created_at
            }
        });
    });
});

module.exports = router;
