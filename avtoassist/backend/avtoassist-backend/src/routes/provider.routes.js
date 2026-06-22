'use strict';
const router = require('express').Router();
const { asyncHandler } = require('../middleware/errorHandler');
const { requireAuth } = require('../middleware/auth.middleware');
const { registerProvider, getMyProvider, setStatus, updateLocation } = require('../controllers/providerController');

router.use(requireAuth);
router.post('/register', asyncHandler(registerProvider));
router.get('/me', asyncHandler(getMyProvider));
router.patch('/me/status', asyncHandler(setStatus));
router.patch('/me/location', asyncHandler(updateLocation));

module.exports = router;
