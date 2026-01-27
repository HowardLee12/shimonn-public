const express = require('express');
const router = express.Router();
const verifyToken = require('../middleware/authMiddleware');
const Contact = require('../models/contactModel');

router.use(verifyToken);

router.get('/', (req, res) => {
    Contact.findByUserId(req.userId, (err, contacts) => {
        if (err) return res.status(500).send("There was a problem finding the contacts.");
        res.status(200).send(contacts);
    });
});

router.post('/', (req, res) => {
    const { name, email, order, custom_subject, custom_body } = req.body;

    // Check limit before creating
    Contact.findByUserId(req.userId, (err, contacts) => {
        if (err) return res.status(500).send("Error checking contact limit.");

        if (contacts.length >= 2) {
            return res.status(403).json({
                error: "Free plan limit reached. maximum 2 contacts allowed."
            });
        }

        Contact.create(req.userId, name, email, order, custom_subject, custom_body, (err, contact) => {
            if (err) return res.status(500).send("There was a problem creating the contact.");
            res.status(200).send(contact);
        });
    });
});

router.put('/:id', (req, res) => {
    const { name, email, order, custom_subject, custom_body } = req.body;
    Contact.update(req.userId, req.params.id, name, email, order, custom_subject, custom_body, (err, contact) => {
        if (err) return res.status(500).send("There was a problem updating the contact.");
        res.status(200).send(contact);
    });
});

router.delete('/:id', (req, res) => {
    Contact.delete(req.params.id, req.userId, (err, changes) => {
        if (err) return res.status(500).send("There was a problem deleting the contact.");
        res.status(200).send({ message: "Contact deleted", changes });
    });
});

module.exports = router;
