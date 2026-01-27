const pool = require('../database');

const CheckIn = {
    createOrUpdate: async (userId, callback) => {
        try {
            const now = new Date();
            const deadline = new Date(now.getTime() + 48 * 60 * 60 * 1000); // 48 hours

            // Check if user already has a checkin record
            const existing = await pool.query(
                `SELECT id, checked_at, streak_days FROM checkins WHERE user_id = $1`,
                [userId]
            );

            if (existing.rows.length > 0) {
                const lastCheckIn = new Date(existing.rows[0].checked_at);
                let currentStreak = existing.rows[0].streak_days || 0;

                // Calculate difference in days (ignoring time)
                const isSameDay = now.toDateString() === lastCheckIn.toDateString();

                // Check if it's the consecutive day
                const yesterday = new Date(now);
                yesterday.setDate(yesterday.getDate() - 1);
                const isConsecutiveDay = yesterday.toDateString() === lastCheckIn.toDateString();

                let newStreak = currentStreak;

                if (isConsecutiveDay) {
                    newStreak = currentStreak + 1;
                } else if (!isSameDay) {
                    // Missed a day or more (but within 48h limit of app, logic might be weird if 48h allowed)
                    // If the user checks in within 48h but it's been > 1 calendar day?
                    // E.g. Checked in Monday 10AM. Deadline Wed 10AM. Checks in Wed 9AM.
                    // Monday -> Wed is 2 days diff. Streak resets?
                    // Ideally streak rewards daily check-in.
                    // If diff > 1, reset to 1.
                    newStreak = 1;
                }
                // If isSameDay, keep streak same.

                // Update existing record
                const result = await pool.query(
                    `UPDATE checkins 
                     SET checked_at = $1, deadline = $2, notified = FALSE, streak_days = $3
                     WHERE user_id = $4 
                     RETURNING *`,
                    [now, deadline, newStreak, userId]
                );
                callback(null, result.rows[0]);
            } else {
                // Create new record
                const result = await pool.query(
                    `INSERT INTO checkins (user_id, checked_at, deadline, notified, streak_days) 
                     VALUES ($1, $2, $3, FALSE, 1) 
                     RETURNING *`,
                    [userId, now, deadline]
                );
                callback(null, result.rows[0]);
            }
        } catch (err) {
            callback(err, null);
        }
    },

    getStatus: async (userId, callback) => {
        try {
            const result = await pool.query(
                `SELECT * FROM checkins WHERE user_id = $1`,
                [userId]
            );
            callback(null, result.rows[0]);
        } catch (err) {
            callback(err, null);
        }
    },

    findOverdue: async (callback) => {
        try {
            const now = new Date();
            const result = await pool.query(
                `SELECT * 
                 FROM checkins 
                 WHERE deadline < $1 AND notified = FALSE`,
                [now]
            );
            callback(null, result.rows);
        } catch (err) {
            callback(err, null);
        }
    },

    markNotified: async (userId, callback) => {
        try {
            const result = await pool.query(
                `UPDATE checkins SET notified = TRUE WHERE user_id = $1 RETURNING *`,
                [userId]
            );
            callback(null, result.rowCount);
        } catch (err) {
            callback(err, null);
        }
    },

    resetNotified: async (userId, callback) => {
        try {
            const result = await pool.query(
                `UPDATE checkins SET notified = FALSE WHERE user_id = $1 RETURNING *`,
                [userId]
            );
            callback(null, result.rowCount);
        } catch (err) {
            callback(err, null);
        }
    }
};

module.exports = CheckIn;
