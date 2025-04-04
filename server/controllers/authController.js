const catchAsync = require('../modules/catchAsync');
const getAccessToken = require('../modules/oauth2');
const serviceKey = require('../service-account-key.json');

exports.bindToken = catchAsync(async (req, res, next) => {
    const token = await getAccessToken();
    req.params.token = token;

    next();
});

exports.bindProject = catchAsync(async (req, res, next) => {
    const projectId = serviceKey.project_id;
    req.params.projectId = projectId;

    next();
});
