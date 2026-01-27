const express = require('express');
const router = express.Router();
const verifyToken = require('../middleware/authMiddleware');
const CheckIn = require('../models/checkinModel');
const { Pool } = require('pg');

router.use(verifyToken);

router.post('/', async (req, res) => {
    try {
        // Check if user is locked
        const pool = new Pool({
            connectionString: process.env.DATABASE_URL,
            ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false
        });

        const userCheck = await pool.query(
            `SELECT u.is_locked, c.deadline 
             FROM users u 
             LEFT JOIN checkins c ON u.id = c.user_id 
             WHERE u.id = $1`,
            [req.userId]
        );

        await pool.end();

        if (userCheck.rows[0]?.is_locked) {
            return res.status(403).json({
                error: 'Account locked. Payment required to reactivate.',
                locked: true
            });
        }

        // Check if deadline has passed
        const deadline = userCheck.rows[0]?.deadline;
        if (deadline && new Date() > new Date(deadline)) {
            return res.status(403).json({
                error: 'Time expired. Account is locking...',
                locked: true
            });
        }

        // Proceed with check-in
        CheckIn.createOrUpdate(req.userId, (err, result) => {
            if (err) return res.status(500).send("There was a problem checking in.");
            res.status(200).send(result);
        });
    } catch (error) {
        console.error('Error checking lock status:', error);
        res.status(500).send("There was a problem checking in.");
    }
});

router.get('/status', async (req, res) => {
    try {
        // Check if user is locked
        const pool = new Pool({
            connectionString: process.env.DATABASE_URL,
            ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false
        });

        const userCheck = await pool.query(
            'SELECT is_locked FROM users WHERE id = $1',
            [req.userId]
        );

        await pool.end();

        const isLocked = userCheck.rows[0]?.is_locked || false;

        // Get check-in status
        CheckIn.getStatus(req.userId, (err, status) => {
            if (err) return res.status(500).send("There was a problem getting status.");

            // Add locked status to response
            const response = status || { message: "No check-in record found" };
            response.locked = isLocked;

            res.status(200).send(response);
        });
    } catch (error) {
        console.error('Error checking status:', error);
        res.status(500).send("There was a problem getting status.");
    }
});

module.exports = router;
