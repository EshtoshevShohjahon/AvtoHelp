'use strict';
const router = require('express').Router();
const { asyncHandler } = require('../middleware/errorHandler');
const { sendOtpHandler, verifyOtpHandler, refreshHandler, logoutHandler } = require('../controllers/authController');

router.post('/send-otp', asyncHandler(sendOtpHandler));
router.post('/verify-otp', asyncHandler(verifyOtpHandler));
router.post('/refresh', asyncHandler(refreshHandler));
router.post('/logout', asyncHandler(logoutHandler));

module.exports = router;
