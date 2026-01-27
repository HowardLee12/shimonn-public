const pool = require('../database');

const Contact = {
    create: async (userId, name, email, order, customSubject, customBody, callback) => {
        try {
            const result = await pool.query(
                `INSERT INTO contacts (user_id, name, email, contact_order, custom_subject, custom_body) 
                 VALUES ($1, $2, $3, $4, $5, $6) 
                 RETURNING *`,
                [userId, name, email, order, customSubject, customBody]
            );
            callback(null, result.rows[0]);
        } catch (err) {
            callback(err, null);
        }
    },

    update: async (userId, contactId, name, email, order, customSubject, customBody, callback) => {
        try {
            const result = await pool.query(
                `UPDATE contacts 
                 SET contact_order = $1, custom_subject = $2, custom_body = $3, updated_at = CURRENT_TIMESTAMP
                 WHERE id = $4 AND user_id = $5
                 RETURNING *`,
                [order, customSubject, customBody, contactId, userId]
            );
            if (result.rows.length === 0) {
                return callback(new Error("Contact not found or unauthorized"), null);
            }
            callback(null, result.rows[0]);
        } catch (err) {
            callback(err, null);
        }
    },

    findByUserId: async (userId, callback) => {
        try {
            const result = await pool.query(
                `SELECT * FROM contacts WHERE user_id = $1 ORDER BY contact_order ASC`,
                [userId]
            );
            callback(null, result.rows);
        } catch (err) {
            callback(err, null);
        }
    },

    delete: async (id, userId, callback) => {
        try {
            const result = await pool.query(
                `DELETE FROM contacts WHERE id = $1 AND user_id = $2`,
                [id, userId]
            );
            callback(null, result.rowCount);
        } catch (err) {
            callback(err, null);
        }
    }
};

module.exports = Contact;
