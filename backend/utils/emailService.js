const nodemailer = require('nodemailer');

// Configure with actual SMTP credentials
const transporter = nodemailer.createTransport({
    service: 'gmail', // or 'ses', 'sendgrid'
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS
    }
});

const sendEmergencyEmail = (to, subject, body) => {
    const mailOptions = {
        from: process.env.EMAIL_USER,
        to: to,
        subject: subject,
        text: body
    };

    transporter.sendMail(mailOptions, (error, info) => {
        if (error) {
            console.log('Error sending email:', error);
        } else {
            console.log('Email sent:', info.response);
        }
    });
};

module.exports = { sendEmergencyEmail };
