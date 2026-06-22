'use strict';
const { User, Vehicle } = require('../models');
const { v4: uuidv4 } = require('uuid');

async function getMe(req, res) {
  const user = await User.findByPk(req.user.id, { attributes: { exclude: ['createdAt', 'updatedAt'] } });
  res.json(user);
}

async function updateMe(req, res) {
  const { name, preferred_language } = req.body;
  const user = await User.findByPk(req.user.id);
  const updates = {};
  if (name !== undefined) updates.name = name;
  if (preferred_language !== undefined) updates.preferred_language = preferred_language;
  await user.update(updates);
  res.json(user);
}

async function listVehicles(req, res) {
  const vehicles = await Vehicle.findAll({ where: { user_id: req.user.id } });
  res.json(vehicles);
}

async function createVehicle(req, res) {
  const { make, model, year, color, plate } = req.body;
  if (!make || !model) return res.status(400).json({ error: 'make and model required' });
  const vehicle = await Vehicle.create({
    id: uuidv4(),
    user_id: req.user.id,
    make,
    model,
    year: year ? parseInt(year) : null,
    color: color || null,
    plate: plate || null,
  });
  res.status(201).json(vehicle);
}

async function deleteVehicle(req, res) {
  const vehicle = await Vehicle.findByPk(req.params.id);
  if (!vehicle) return res.status(404).json({ error: 'not found' });
  if (vehicle.user_id !== req.user.id) return res.status(403).json({ error: 'forbidden' });
  await vehicle.destroy();
  res.json({ ok: true });
}

module.exports = { getMe, updateMe, listVehicles, createVehicle, deleteVehicle };
