'use strict';
const { PartsStore, PartsInventory, Workshop, WorkshopService } = require('../models');
const { haversineKm } = require('../utils/haversine');
const { Op } = require('sequelize');

async function nearbyPartsStores(req, res) {
  const { lat, lon, radius = 10 } = req.query;
  if (!lat || !lon) return res.status(400).json({ error: 'lat and lon required' });
  const stores = await PartsStore.findAll({ where: { is_active: true } });
  const result = stores
    .map(s => ({ ...s.toJSON(), distance_km: haversineKm(parseFloat(lat), parseFloat(lon), s.lat, s.lon) }))
    .filter(s => s.distance_km <= parseFloat(radius))
    .sort((a, b) => a.distance_km - b.distance_km)
    .slice(0, 20);
  res.json(result);
}

async function storeInventory(req, res) {
  const items = await PartsInventory.findAll({ where: { store_id: req.params.id, in_stock: true } });
  res.json(items);
}

async function nearbyWorkshops(req, res) {
  const { lat, lon, radius = 10 } = req.query;
  if (!lat || !lon) return res.status(400).json({ error: 'lat and lon required' });
  const workshops = await Workshop.findAll({ where: { is_active: true } });
  const result = workshops
    .map(w => ({ ...w.toJSON(), distance_km: haversineKm(parseFloat(lat), parseFloat(lon), w.lat, w.lon) }))
    .filter(w => w.distance_km <= parseFloat(radius))
    .sort((a, b) => a.distance_km - b.distance_km)
    .slice(0, 20);
  res.json(result);
}

async function workshopDetail(req, res) {
  const workshop = await Workshop.findByPk(req.params.id, {
    include: [{ model: WorkshopService, as: 'services' }],
  });
  if (!workshop) return res.status(404).json({ error: 'not found' });
  res.json(workshop);
}

module.exports = { nearbyPartsStores, storeInventory, nearbyWorkshops, workshopDetail };
