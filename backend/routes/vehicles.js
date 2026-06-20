const express = require('express');
const router = express.Router();
const vehicleController = require('../controllers/vehicleController');
const { authMiddleware } = require('../middleware/auth');

// All vehicle routes require authentication
router.use(authMiddleware);

// Vehicle CRUD
router.post('/', vehicleController.addVehicle);
router.get('/', vehicleController.getUserVehicles);
router.get('/:id', vehicleController.getVehicleById);
router.put('/:id', vehicleController.updateVehicle);
router.delete('/:id', vehicleController.deleteVehicle);

// Oil change management
router.post('/:vehicle_id/oil-changes', vehicleController.addOilChange);
router.get('/:vehicle_id/oil-changes', vehicleController.getOilChangeHistory);

// Maintenance reminders
router.get('/reminders/all', vehicleController.getMaintenanceReminders);

module.exports = router;
