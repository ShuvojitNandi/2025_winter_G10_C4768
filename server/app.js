const express = require('express');
const helmet = require('helmet');
const morgan = require('morgan');
const xss = require('xss-clean');
const testRouter = require('./routes/testRouter');
const messageRouter = require('./routes/messageRouter');

const admin = require('firebase-admin');
const serviceAccount = require('./service-account-key.json');

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
});

const app = express();
app.use(helmet());
if (process.env.NODE_ENV === 'development') app.use(morgan('dev'));

app.use(express.json({ limit: '10kb' }));
app.use(xss());

app.get('/', (req, res) => {
    res.status(200).json({
        status: 'success',
        data: {
            message: `Welcome to harvest!`,
            url: `${req.protocol || 'https'}://${req.get('host')}`,
        },
    });
});

app.use('/test', testRouter);
app.use('/api/message', messageRouter);

app.all('*', (req, res, next) => {
    res.status(404).json({
        status: 'fail',
        message: `Can't find ${req.originalUrl} on this server!`,
    });
});

module.exports = app;
