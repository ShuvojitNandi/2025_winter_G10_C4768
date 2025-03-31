const axios = require('axios');

class DeviceMessage {
    constructor(device, title, body) {
        this.device = device;
        this.title = title;
        this.body = body;
    }

    json() {
        return {
            token: this.device,
            notification: {
                title: this.title,
                body: this.body,
            },
            data: {
                type: 'DEVICE',
            },
        };
    }
}

class TopicMessage {
    constructor(topic, title, body) {
        this.topic = topic;
        this.title = title;
        this.body = body;
    }

    json() {
        return {
            topic: this.topic,
            notification: {
                title: this.title,
                body: this.body,
            },
            data: {
                type: 'TOPIC',
                topic: this.topic,
            },
        };
    }
}

exports.TopicMessage = TopicMessage;
exports.DeviceMessage = DeviceMessage;

/**
 *
 * @param {TopicMessage} topicMessage
 * @param {String} accessToken
 * @param {String} projectId
 */

async function sendNotificationToTopic(topicMessage, accessToken, projectId) {
    const url = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;

    const message = {
        message: topicMessage.json(),
    };

    try {
        const response = await axios.post(url, message, {
            headers: {
                Authorization: `Bearer ${accessToken.trim()}`,
                'Content-Type': 'application/json',
            },
        });

        return {
            success: true,
            response: response.data,
        };
    } catch (error) {
        return {
            success: false,
            response: error.response?.data ?? error.message,
        };
    }
}

/**
 *
 * @param {DeviceMessage} deviceMessage
 * @param {String} accessToken
 * @param {String} projectId
 */

async function sendNotificationToDevice(deviceMessage, accessToken, projectId) {
    const url = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;

    const message = {
        message: deviceMessage.json(),
    };

    try {
        const response = await axios.post(url, message, {
            headers: {
                Authorization: `Bearer ${accessToken.trim()}`,
                'Content-Type': 'application/json',
            },
        });

        return {
            success: true,
            response: response.data,
        };
    } catch (error) {
        return {
            success: false,
            response: error.response?.data ?? error.message,
        };
    }
}
exports.sendNotificationToTopic = sendNotificationToTopic;
exports.sendNotificationToDevice = sendNotificationToDevice;
