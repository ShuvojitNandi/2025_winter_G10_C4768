const catchAsync = require('../modules/catchAsync');
const messagingAPI = require('../modules/messagingAPI');

exports.sendMessageToTopic = catchAsync(async (req, res, next) => {
    const token = req.params.token;
    const projectId = req.params.projectId;
    const topic = req.params.topic;

    const title = req.body.title;
    const body = req.body.body;

    const message = new messagingAPI.TopicMessage(topic, title, body);

    const result = await messagingAPI.sendNotificationToTopic(
        message,
        token,
        projectId
    );

    res.status(200).json({
        status: 'success',
        message: message.json(),
        result: result.response,
    });
});

exports.sendMessageToDevice = catchAsync(async (req, res, next) => {
    const token = req.params.token;
    const projectId = req.params.projectId;
    const device = req.params.device;
    const title = req.body.title;
    const body = req.body.body;

    const message = new messagingAPI.DeviceMessage(device, title, body);

    const result = await messagingAPI.sendNotificationToDevice(
        message,
        token,
        projectId
    );

    res.status(200).json({
        status: 'success',
        message: message.json(),
        result: result.response,
    });
});
