'use strict';
const { PartsStore, PartsInventory, Workshop, WorkshopService } = require('../models');
const { haversineKm } = require('../utils/haversine');
const { Op } = require('sequelize');

async function nearbyPartsStores(req, res) {
  const { lat, radius = 10 } = req.query;
  const lng = req.query.lng ?? req.query.lon;
  if (!lat || !lng) return res.status(400).json({ error: 'lat and lng required' });
  const stores = await PartsStore.findAll({ where: { is_active: true } });
  const result = stores
    .map(s => ({ ...s.toJSON(), distance_km: haversineKm(parseFloat(lat), parseFloat(lng), s.lat, s.lng) }))
    .filter(s => s.distance_km <= parseFloat(radius))
    .sort((a, b) => a.distance_km - b.distance_km)
    .slice(0, 20);
  res.json({ stores: result });
}

async function storeInventory(req, res) {
  const items = await PartsInventory.findAll({
    where: { store_id: req.params.id, stock_qty: { [Op.gt]: 0 } },
  });
  res.json(items);
}

function _workshopQuery(category) {
  return {
    is_active: true,
    vehicle_category: category === 'truck'
      ? { [Op.in]: ['truck', 'both'] }
      : { [Op.in]: ['light', 'both'] },
  };
}

async function nearbyWorkshops(req, res) {
  const { lat, radius = 10 } = req.query;
  const lng = req.query.lng ?? req.query.lon;
  if (!lat || !lng) return res.status(400).json({ error: 'lat and lng required' });
  const workshops = await Workshop.findAll({ where: _workshopQuery('light') });
  const result = workshops
    .map(w => ({ ...w.toJSON(), distance_km: haversineKm(parseFloat(lat), parseFloat(lng), w.lat, w.lng) }))
    .filter(w => w.distance_km <= parseFloat(radius))
    .sort((a, b) => a.distance_km - b.distance_km)
    .slice(0, 20);
  res.json({ workshops: result });
}

async function nearbyTruckWorkshops(req, res) {
  const { lat, radius = 30 } = req.query;
  const lng = req.query.lng ?? req.query.lon;
  if (!lat || !lng) return res.status(400).json({ error: 'lat and lng required' });
  const workshops = await Workshop.findAll({ where: _workshopQuery('truck') });
  const result = workshops
    .map(w => ({ ...w.toJSON(), distance_km: haversineKm(parseFloat(lat), parseFloat(lng), w.lat, w.lng) }))
    .filter(w => w.distance_km <= parseFloat(radius))
    .sort((a, b) => a.distance_km - b.distance_km)
    .slice(0, 30);
  res.json({ workshops: result });
}

async function workshopDetail(req, res) {
  const workshop = await Workshop.findByPk(req.params.id, {
    include: [{ model: WorkshopService, as: 'services' }],
  });
  if (!workshop) return res.status(404).json({ error: 'not found' });
  res.json(workshop);
}

async function allWorkshops(req, res) {
  const category = req.query.category || 'light';
  const workshops = await Workshop.findAll({
    where: _workshopQuery(category),
    attributes: ['id', 'name', 'address', 'lat', 'lng', 'specializations',
                 'rating_avg', 'rating_count', 'phone', 'website', 'vehicle_category'],
    order: [['rating_avg', 'DESC']],
    limit: 500,
  });
  res.json({ workshops });
}

async function syncOsmWorkshops(req, res) {
  if (req.user.role !== 'admin') return res.status(403).json({ error: 'admin only' });
  const { syncWorkshopsFromOSM } = require('../services/osmSyncService');
  const result = await syncWorkshopsFromOSM();
  res.json({ ok: true, ...result });
}

module.exports = {
  nearbyPartsStores, storeInventory,
  nearbyWorkshops, nearbyTruckWorkshops,
  allWorkshops, workshopDetail, syncOsmWorkshops,
};
