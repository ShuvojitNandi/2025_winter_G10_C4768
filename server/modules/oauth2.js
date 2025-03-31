const { GoogleAuth } = require('google-auth-library');
const path = require('path');

let cachedToken = '';
let expireTime = 0;

function isExpired() {
    return performance.now() > expireTime;
}

function updateExpireTime(minutes, hours, days) {
    minutes = minutes ? minutes * 1000 * 60 : 0;
    hours = hours ? hours * 1000 * 60 * 60 : 0;
    days = days ? days * 1000 * 60 * 60 * 24 : 0;

    const additionalTime = minutes + hours + days;
    expireTime = performance.now() + additionalTime;
}

async function getAccessToken() {
    if (!isExpired() && cachedToken) return cachedToken;
    updateExpireTime(30);

    // Load service account key file
    const keyFilePath = path.join(__dirname, '../service-account-key.json');

    // Define the required scope for Firebase Cloud Messaging
    const SCOPES = ['https://www.googleapis.com/auth/firebase.messaging'];

    // Authenticate using the service account
    const auth = new GoogleAuth({
        keyFile: keyFilePath,
        scopes: SCOPES,
    });

    // Get an access token
    const client = await auth.getClient();
    const token = await client.getAccessToken();

    cachedToken = token.token;

    return cachedToken;
}

module.exports = getAccessToken;
