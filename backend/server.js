require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const db = require('./database');
const cronService = require('./services/cronService');

const app = express();
const PORT = process.env.PORT || 3000;

// Start cron job for monitoring check-ins
cronService.startCronJob();

// Middleware - MUST come before routes
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request logging middleware
app.use((req, res, next) => {
    console.log(`[REQUEST] ${req.method} ${req.url} from ${req.ip}`);
    if (req.method === 'POST') {
        console.log('[BODY]', JSON.stringify(req.body));
    }
    next();
});

// Root route
app.get('/', (req, res) => {
    res.json({ message: "Dead Man's Switch API is running" });
});

// Test route
app.get('/api/test', (req, res) => {
    res.json({ message: "API test route works!" });
});

// Import and register routes
const authRoutes = require('./routes/auth');
const contactsRoutes = require('./routes/contacts');
const checkInRoutes = require('./routes/checkin');
const testEmailRoutes = require('./routes/testEmail');
const messagesRoutes = require('./routes/messages');

app.use('/api/auth', authRoutes);
app.use('/api/contacts', contactsRoutes);
app.use('/api/checkin', checkInRoutes);
app.use('/api/test-email', testEmailRoutes);
app.use('/api/messages', messagesRoutes);

console.log('✅ Routes registered: /api/auth, /api/contacts, /api/checkin, /api/test-email, /api/messages');

// 404 handler
app.use((req, res) => {
    res.status(404).json({ error: 'Route not found', path: req.path });
});

// Error handler
app.use((err, req, res, next) => {
    console.error('Error:', err);
    res.status(500).json({ error: 'Internal server error', message: err.message });
});

if (require.main === module) {
    app.listen(PORT, () => {
        console.log(`Server is running on port ${PORT}`);
    });
}

module.exports = app;
