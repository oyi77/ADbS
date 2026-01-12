const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 3001;
const TASKS_FILE = path.join(__dirname, '..', '.workflow-enforcer', 'tasks.json');

const server = http.createServer((req, res) => {
    // Set CORS headers
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
        res.writeHead(204);
        res.end();
        return;
    }

    if (req.url === '/api/tasks' && req.method === 'GET') {
        fs.readFile(TASKS_FILE, 'utf8', (err, data) => {
            if (err) {
                if (err.code === 'ENOENT') {
                     // If file doesn't exist, return empty tasks list
                    res.writeHead(200, { 'Content-Type': 'application/json' });
                    res.end(JSON.stringify({ tasks: [] }));
                } else {
                    res.writeHead(500, { 'Content-Type': 'application/json' });
                    res.end(JSON.stringify({ error: 'Failed to read tasks file' }));
                }
                return;
            }
            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(data);
        });
    } else {
        res.writeHead(404, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Not Found' }));
    }
});

server.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}/`);
});
