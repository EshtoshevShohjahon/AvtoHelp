'use strict';
const router = require('express').Router();
const { asyncHandler } = require('../middleware/errorHandler');
const { requireAuth } = require('../middleware/auth.middleware');
const { registerProvider, getMyProvider, setStatus, updateLocation } = require('../controllers/providerController');
const { vehicleLookup, addRecordByProvider } = require('../controllers/providerVehicleController');
const { getMyStats, getPublicStats } = require('../controllers/providerStatsController');

router.use(requireAuth);
router.post('/register', asyncHandler(registerProvider));
router.get('/me', asyncHandler(getMyProvider));
router.get('/me/stats', asyncHandler(getMyStats));
router.patch('/me/status', asyncHandler(setStatus));
router.patch('/me/location', asyncHandler(updateLocation));

router.get('/vehicle-lookup', asyncHandler(vehicleLookup));
router.post('/vehicle-lookup/:vehicleId/service-records', asyncHandler(addRecordByProvider));

// Ommaviy: mijoz ustani tanlashdan oldin statistikasini ko'radi
router.get('/:id/stats', asyncHandler(getPublicStats));

module.exports = router;
