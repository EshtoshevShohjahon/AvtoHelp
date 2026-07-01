'use strict';
const router = require('express').Router();
const { asyncHandler } = require('../middleware/errorHandler');
const { requireAuth } = require('../middleware/auth.middleware');
const {
  nearbyWorkshops, nearbyTruckWorkshops,
  allWorkshops, workshopDetail, syncOsmWorkshops,
} = require('../controllers/catalogController');

router.use(requireAuth);
router.get('/nearby',       asyncHandler(nearbyWorkshops));
router.get('/nearby-truck', asyncHandler(nearbyTruckWorkshops));
router.get('/all',          asyncHandler(allWorkshops));
router.post('/sync-osm',    asyncHandler(syncOsmWorkshops));
router.get('/:id',          asyncHandler(workshopDetail));

module.exports = router;
