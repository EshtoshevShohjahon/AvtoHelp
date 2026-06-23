const router = require('express').Router();
const { requireAuth } = require('../middleware/auth.middleware');
const { getMe, updateMe, listVehicles, lookupVehicle, createVehicle, deleteVehicle } = require('../controllers/userController');
const { asyncHandler } = require('../middleware/errorHandler');
const { listRecords, createRecord, deleteRecord, updateOdometer } = require('../controllers/serviceRecordController');

router.use(requireAuth);

router.get('/me', getMe);
router.patch('/me', updateMe);

router.get('/me/vehicles', listVehicles);
router.get('/me/vehicles/lookup', lookupVehicle);
router.post('/me/vehicles', createVehicle);
router.delete('/me/vehicles/:id', deleteVehicle);

router.get('/me/vehicles/:vehicleId/service-records', asyncHandler(listRecords));
router.post('/me/vehicles/:vehicleId/service-records', asyncHandler(createRecord));
router.delete('/me/vehicles/:vehicleId/service-records/:id', asyncHandler(deleteRecord));
router.patch('/me/vehicles/:vehicleId/odometer', asyncHandler(updateOdometer));

module.exports = router;
