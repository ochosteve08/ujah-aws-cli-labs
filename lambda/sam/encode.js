const fs = require('fs');

// Read the JSON payload from a file
const payload = JSON.parse(fs.readFileSync('payload.json', 'utf8'));

// Convert the JSON payload to a string
const jsonPayload = JSON.stringify(payload);

// Encode the JSON payload in base64
const base64Payload = Buffer.from(jsonPayload).toString('base64');

console.log(base64Payload);
