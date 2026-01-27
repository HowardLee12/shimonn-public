const pool = require('../database');
const bcrypt = require('bcryptjs');

const User = {
    // Find or create user by device ID (main authentication method)
    findOrCreateByDeviceID: async (deviceID, deviceType, callback) => {
        try {
            // Try to find existing user
            let result = await pool.query(
                `SELECT id, device_id, device_type, created_at, last_device_sync FROM users WHERE device_id = $1`,
                [deviceID]
            );

            if (result.rows.length > 0) {
                // Update last sync time
                await pool.query(
                    `UPDATE users SET last_device_sync = CURRENT_TIMESTAMP WHERE device_id = $1`,
                    [deviceID]
                );
                callback(null, result.rows[0]);
            } else {
                // Create new user
                result = await pool.query(
                    `INSERT INTO users (device_id, device_type, last_device_sync) 
                     VALUES ($1, $2, CURRENT_TIMESTAMP) 
                     RETURNING id, device_id, device_type, created_at, last_device_sync`,
                    [deviceID, deviceType || 'iOS']
                );
                callback(null, result.rows[0]);
            }
        } catch (err) {
            callback(err, null);
        }
    },

    findById: async (id, callback) => {
        try {
            const result = await pool.query(
                `SELECT id, device_id, device_type, created_at, last_device_sync FROM users WHERE id = $1`,
                [id]
            );
            callback(null, result.rows[0]);
        } catch (err) {
            callback(err, null);
        }
    }
};

module.exports = User;
