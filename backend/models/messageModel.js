const pool = require('../database');

const Message = {
    findByUserId: async (userId, callback) => {
        try {
            const result = await pool.query(
                `SELECT * FROM messages WHERE user_id = $1`,
                [userId]
            );
            callback(null, result.rows[0]);
        } catch (err) {
            callback(err, null);
        }
    },

    createOrUpdate: async (userId, subject, body, callback) => {
        try {
            // Use PostgreSQL's ON CONFLICT for upsert
            const result = await pool.query(
                `INSERT INTO messages (user_id, subject, body) 
                 VALUES ($1, $2, $3) 
                 ON CONFLICT (user_id) 
                 DO UPDATE SET subject = $2, body = $3, updated_at = CURRENT_TIMESTAMP
                 RETURNING *`,
                [userId, subject, body]
            );
            callback(null, result.rows[0]);
        } catch (err) {
            callback(err, null);
        }
    }
};

module.exports = Message;
