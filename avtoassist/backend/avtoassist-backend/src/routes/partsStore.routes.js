'use strict';
const router = require('express').Router();
const { asyncHandler } = require('../middleware/errorHandler');
const { requireAuth } = require('../middleware/auth.middleware');
const { nearbyPartsStores, storeInventory } = require('../controllers/catalogController');

router.use(requireAuth);
router.get('/nearby', asyncHandler(nearbyPartsStores));
router.get('/:id/inventory', asyncHandler(storeInventory));

module.exports = router;
