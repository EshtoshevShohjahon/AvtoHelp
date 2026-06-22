'use strict';
const router = require('express').Router();
const { asyncHandler } = require('../middleware/errorHandler');
const { requireAuth } = require('../middleware/auth.middleware');
const { nearbyWorkshops, workshopDetail } = require('../controllers/catalogController');

router.use(requireAuth);
router.get('/nearby', asyncHandler(nearbyWorkshops));
router.get('/:id', asyncHandler(workshopDetail));

module.exports = router;
