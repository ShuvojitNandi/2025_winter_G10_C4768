const functions = require('firebase-functions');
require('dotenv').config();
const app = require('./app');

// const port = process.env.PORT || 3000;

// // const getUrl = () =>
// //     (process.env?.URL ?? `127.0.0.1:${port}`).replace(/<PORT>/g, port);

// const buildServer = async () => {
//     app.listen(port, () => {
//         console.log(`Running on port ${port}`);
//     });
// };

// const init = async () => {
//     buildServer();
// };

// init();

exports.api = functions.https.onRequest(app);
