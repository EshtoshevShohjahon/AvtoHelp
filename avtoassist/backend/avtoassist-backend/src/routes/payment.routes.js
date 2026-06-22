'use strict';
const router = require('express').Router();
const { asyncHandler } = require('../middleware/errorHandler');
const { requireAuth } = require('../middleware/auth.middleware');
const { chargePayment } = require('../controllers/paymentController');

router.use(requireAuth);
router.post('/', asyncHandler(chargePayment));

module.exports = router;
