const catchAsync = require('../modules/catchAsync');

exports.get = catchAsync(async (req, res, next) => {
    res.status(200).json({
        status: 'success',
    });
});

exports.getToken = catchAsync(async (req, res, next) => {
    res.status(200).json({
        status: 'success',
        token: req.params.token,
    });
});

exports.post = catchAsync(async (req, res, next) => {
    res.status(200).json({
        status: 'success',
    });
});
