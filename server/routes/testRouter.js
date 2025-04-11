const router = require('express').Router();
const testController = require('../controllers/test');
const auth = require('../controllers/authController');

router.route('/').get(testController.get).post(testController.post);

router.route('/token').get(auth.bindToken, testController.getToken);

module.exports = router;
