'use strict';
const { v4: uuidv4 } = require('uuid');
const { Vehicle, ServiceRecord } = require('../models');
const { asyncHandler } = require('../middleware/errorHandler');

// GET /api/users/me/vehicles/:vehicleId/service-records
const listRecords = asyncHandler(async (req, res) => {
  const vehicle = await Vehicle.findOne({
    where: { id: req.params.vehicleId, user_id: req.user.id },
  });
  if (!vehicle) return res.status(404).json({ error: 'Vehicle not found' });

  const records = await ServiceRecord.findAll({
    where: { vehicle_id: vehicle.id },
    order: [['service_date', 'DESC'], ['created_at', 'DESC']],
  });

  // Moy almashtirish eslatmasi
  const lastOil = records.find(r => r.service_type === 'oil_change');
  const oilAlert = lastOil && lastOil.next_service_km
    ? {
        last_change_km: lastOil.odometer_km,
        next_change_km: lastOil.next_service_km,
        current_km: vehicle.current_odometer || 0,
        km_left: lastOil.next_service_km - (vehicle.current_odometer || 0),
        alert: (lastOil.next_service_km - (vehicle.current_odometer || 0)) <= 500,
      }
    : null;

  res.json({ records, vehicle, oil_alert: oilAlert });
});

// POST /api/users/me/vehicles/:vehicleId/service-records
const createRecord = asyncHandler(async (req, res) => {
  const vehicle = await Vehicle.findOne({
    where: { id: req.params.vehicleId, user_id: req.user.id },
  });
  if (!vehicle) return res.status(404).json({ error: 'Vehicle not found' });

  const {
    service_type, service_date, odometer_km,
    workshop_name, mechanic_name, cost, notes, next_service_km,
  } = req.body;

  if (!service_type || !service_date || odometer_km == null) {
    return res.status(400).json({ error: 'service_type, service_date, odometer_km required' });
  }

  const record = await ServiceRecord.create({
    id: uuidv4(),
    vehicle_id: vehicle.id,
    service_type,
    service_date,
    odometer_km: Number(odometer_km),
    workshop_name,
    mechanic_name,
    cost: cost ? Number(cost) : null,
    notes,
    next_service_km: next_service_km ? Number(next_service_km) : null,
  });

  // Hozirgi km ni yangilaymiz
  if (Number(odometer_km) > (vehicle.current_odometer || 0)) {
    await vehicle.update({ current_odometer: Number(odometer_km) });
  }

  res.status(201).json({ record, vehicle });
});

// DELETE /api/users/me/vehicles/:vehicleId/service-records/:id
const deleteRecord = asyncHandler(async (req, res) => {
  const vehicle = await Vehicle.findOne({
    where: { id: req.params.vehicleId, user_id: req.user.id },
  });
  if (!vehicle) return res.status(404).json({ error: 'Vehicle not found' });

  const record = await ServiceRecord.findOne({
    where: { id: req.params.id, vehicle_id: vehicle.id },
  });
  if (!record) return res.status(404).json({ error: 'Record not found' });

  await record.destroy();
  res.json({ ok: true });
});

// PATCH /api/users/me/vehicles/:vehicleId/odometer
const updateOdometer = asyncHandler(async (req, res) => {
  const vehicle = await Vehicle.findOne({
    where: { id: req.params.vehicleId, user_id: req.user.id },
  });
  if (!vehicle) return res.status(404).json({ error: 'Vehicle not found' });

  const { current_odometer } = req.body;
  if (current_odometer == null) return res.status(400).json({ error: 'current_odometer required' });

  await vehicle.update({ current_odometer: Number(current_odometer) });
  res.json({ vehicle });
});

module.exports = { listRecords, createRecord, deleteRecord, updateOdometer };
