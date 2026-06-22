const router = require('express').Router();
const { requireAuth } = require('../middleware/auth.middleware');
const { getMe, updateMe, listVehicles, lookupVehicle, createVehicle, deleteVehicle } = require('../controllers/userController');

router.use(requireAuth);

router.get('/me', getMe);
router.patch('/me', updateMe);

router.get('/me/vehicles', listVehicles);
router.get('/me/vehicles/lookup', lookupVehicle);
router.post('/me/vehicles', createVehicle);
router.delete('/me/vehicles/:id', deleteVehicle);

module.exports = router;
