'use strict';
const router = require('express').Router();
const { asyncHandler } = require('../middleware/errorHandler');
const { requireAuth } = require('../middleware/auth.middleware');
const { getMe, updateMe, listVehicles, createVehicle, deleteVehicle } = require('../controllers/userController');

router.use(requireAuth);
router.get('/me', asyncHandler(getMe));
router.patch('/me', asyncHandler(updateMe));
router.get('/me/vehicles', asyncHandler(listVehicles));
router.post('/me/vehicles', asyncHandler(createVehicle));
router.delete('/me/vehicles/:id', asyncHandler(deleteVehicle));

module.exports = router;
