'use strict';
const { Order } = require('../models');
const matchingService = require('../services/matchingService');
const { v4: uuidv4 } = require('uuid');

const VALID_TRANSITIONS = {
  searching: ['accepted', 'cancelled'],
  accepted: ['en_route', 'cancelled'],
  en_route: ['in_progress'],
  in_progress: ['completed'],
  completed: [],
  cancelled: [],
};

async function createOrder(req, res) {
  const { service_type, pickup_lat, pickup_lon, destination_lat, destination_lon, problem_type, notes } = req.body;
  if (!service_type || pickup_lat == null || pickup_lon == null) {
    return res.status(400).json({ error: 'service_type, pickup_lat, pickup_lon required' });
  }
  const order = await Order.create({
    id: uuidv4(),
    customer_id: req.user.id,
    service_type,
    pickup_lat: parseFloat(pickup_lat),
    pickup_lon: parseFloat(pickup_lon),
    destination_lat: destination_lat ? parseFloat(destination_lat) : null,
    destination_lon: destination_lon ? parseFloat(destination_lon) : null,
    problem_type: problem_type || null,
    notes: notes || null,
    status: 'searching',
  });

  const io = req.app.get('io');
  try {
    const provider = await matchingService.findNearestProvider(service_type, parseFloat(pickup_lat), parseFloat(pickup_lon));
    if (provider) {
      await order.update({ provider_id: provider.id, status: 'accepted' });
      if (io) io.to(`provider_${provider.id}`).emit('new_order', { orderId: order.id });
    }
  } catch (_) { /* matching failure is non-fatal */ }

  if (io) io.to(`order_${order.id}`).emit('order_update', { status: order.status });
  res.status(201).json(order);
}

async function getOrder(req, res) {
  const order = await Order.findByPk(req.params.id);
  if (!order) return res.status(404).json({ error: 'not found' });
  if (order.customer_id !== req.user.id && req.user.role !== 'admin') {
    return res.status(403).json({ error: 'forbidden' });
  }
  res.json(order);
}

async function listMyOrders(req, res) {
  const orders = await Order.findAll({
    where: { customer_id: req.user.id },
    order: [['createdAt', 'DESC']],
    limit: 50,
  });
  res.json(orders);
}

async function updateOrderStatus(req, res) {
  const { status } = req.body;
  const order = await Order.findByPk(req.params.id);
  if (!order) return res.status(404).json({ error: 'not found' });

  const allowed = VALID_TRANSITIONS[order.status] || [];
  if (!allowed.includes(status)) {
    return res.status(422).json({ error: `cannot transition from ${order.status} to ${status}` });
  }
  await order.update({ status });
  const io = req.app.get('io');
  if (io) io.to(`order_${order.id}`).emit('order_update', { status });
  res.json(order);
}

module.exports = { createOrder, getOrder, listMyOrders, updateOrderStatus };
