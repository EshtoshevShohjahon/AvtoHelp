'use strict';
const { v4: uuidv4 } = require('uuid');
const { Vehicle, ServiceRecord, User } = require('../models');
const { asyncHandler } = require('../middleware/errorHandler');

// GET /api/providers/vehicle-lookup?tech_passport=AAF1234567
// Provider tex passport bo'yicha ixtiyoriy avtomobilni topadi va tarixini ko'radi
const vehicleLookup = asyncHandler(async (req, res) => {
  const { tech_passport } = req.query;
  if (!tech_passport) {
    return res.status(400).json({ error: 'tech_passport required' });
  }

  const normalized = String(tech_passport).toUpperCase().replace(/\s+/g, '');
  const vehicle = await Vehicle.findOne({ where: { tech_passport: normalized } });
  if (!vehicle) {
    return res.status(404).json({ error: 'Avtomobil topilmadi' });
  }

  const records = await ServiceRecord.findAll({
    where: { vehicle_id: vehicle.id },
    attributes: { exclude: ['cost'] }, // narx faqat mijozga ko'rinadi
    order: [['service_date', 'DESC'], ['created_at', 'DESC']],
  });

  // Moy eslatmasi hisobi
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

  res.json({ vehicle, records, oil_alert: oilAlert });
});

// POST /api/providers/vehicle-lookup/:vehicleId/service-records
// Provider o'zi xizmat ko'rsatgan avtomobilga yozuv qo'shadi
const addRecordByProvider = asyncHandler(async (req, res) => {
  const vehicle = await Vehicle.findByPk(req.params.vehicleId);
  if (!vehicle) {
    return res.status(404).json({ error: 'Avtomobil topilmadi' });
  }

  const {
    service_type, service_date, odometer_km,
    workshop_name, mechanic_name, cost, notes, next_service_km,
  } = req.body;

  if (!service_type || !service_date || odometer_km == null) {
    return res.status(400).json({ error: 'service_type, service_date, odometer_km required' });
  }

  // Usta o'z ismini va ustaxona nomini avtomatik to'ldiradi
  const providerName = req.user.full_name || mechanic_name;

  const record = await ServiceRecord.create({
    id: uuidv4(),
    vehicle_id: vehicle.id,
    service_type,
    service_date,
    odometer_km: Number(odometer_km),
    workshop_name: workshop_name || null,
    mechanic_name: providerName || mechanic_name || null,
    cost: cost ? Number(cost) : null,
    notes,
    next_service_km: next_service_km ? Number(next_service_km) : null,
    added_by_provider_id: req.user.id,
  });

  // Hozirgi km ni yangilaymiz
  if (Number(odometer_km) > (vehicle.current_odometer || 0)) {
    await vehicle.update({ current_odometer: Number(odometer_km) });
  }

  res.status(201).json({ record, vehicle });
});

module.exports = { vehicleLookup, addRecordByProvider };
