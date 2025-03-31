const router = require('express').Router();
const auth = require('../controllers/authController');
const messageController = require('../controllers/messageController');

router
    .route('/topic/:topic')
    .post(
        auth.bindToken,
        auth.bindProject,
        messageController.sendMessageToTopic
    );

router
    .route('/device/:device')
    .post(
        auth.bindToken,
        auth.bindProject,
        messageController.sendMessageToDevice
    );

module.exports = router;
