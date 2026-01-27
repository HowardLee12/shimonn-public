const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const dbPath = path.join(__dirname, 'deadmansswitch.sqlite');
const db = new sqlite3.Database(dbPath);

db.all("SELECT * FROM users", [], (err, rows) => {
    if (err) {
        throw err;
    }
    console.log("Users:", rows);
    db.close();
});
