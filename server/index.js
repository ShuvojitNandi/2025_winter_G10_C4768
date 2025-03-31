require('dotenv').config();
const app = require('./app');
const getToken = require('./modules/oauth2');
const port = process.env.PORT || 3000;

// const getUrl = () =>
//     (process.env?.URL ?? `127.0.0.1:${port}`).replace(/<PORT>/g, port);

const buildServer = async () => {
    app.listen(port, () => {
        console.log(`Running on port ${port}`);
    });
};

const init = async () => {
    buildServer();
};

init();
