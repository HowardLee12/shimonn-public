const request = require('supertest');
const app = require('../server');
const db = require('../database');

describe('API Endpoints', () => {

    // Cleanup users after tests if needed, or use a test DB
    // For simplicity, we just test the health check and a registration flow

    it('GET / should return health check message', async () => {
        const res = await request(app).get('/');
        expect(res.statusCode).toEqual(200);
        expect(res.body).toHaveProperty('message');
    });

    let token;

    it('POST /auth/register should create a new user', async () => {
        const res = await request(app)
            .post('/auth/register')
            .send({
                email: 'test_' + Date.now() + '@example.com',
                password: 'password123'
            });

        expect(res.statusCode).toEqual(200);
        expect(res.body).toHaveProperty('auth', true);
        expect(res.body).toHaveProperty('token');
        token = res.body.token; // Save for later
    });

    it('GET /checkin/status should return status for authenticated user', async () => {
        const res = await request(app)
            .get('/checkin/status')
            .set('x-access-token', token); // Use the token

        expect(res.statusCode).toEqual(200);
        // It might be "No check-in record found" or a record depending on implementation details
        // but it should be 200 OK.
    });

    it('GET /checkin/status should fail without token', async () => {
        const res = await request(app).get('/checkin/status');
        expect(res.statusCode).toEqual(403);
    });
});
