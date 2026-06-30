'use strict';
const { Order } = require('../models');
const { Payment } = require('../models/Payment');
const matchingService = require('../services/matchingService');
const { notify } = require('../services/notificationService');
const { v4: uuidv4 } = require('uuid');

// Status uchun mijozga ko'rinadigan matnlar
const STATUS_MESSAGES = {
  accepted:    'Buyurtmangiz qabul qilindi',
  en_route:    'Usta yo\'lda',
  in_progress: 'Ish boshlandi',
  completed:   'Buyurtma yakunlandi',
  cancelled:   'Buyurtma bekor qilindi',
};

// Qaysi statusdan qaysi statusga o'tish mumkin (umumiy)
const VALID_TRANSITIONS = {
  searching:   ['accepted', 'cancelled'],
  accepted:    ['en_route', 'cancelled'],
  en_route:    ['in_progress', 'cancelled'],
  in_progress: ['completed'],
  completed:   [],
  cancelled:   [],
};

// Provider faqat shu o'tishlarga ruxsat berilgan (bekor qilish yo'q)
const PROVIDER_TRANSITIONS = {
  searching:   ['accepted'],
  accepted:    ['en_route'],
  en_route:    ['in_progress'],
  in_progress: ['completed'],
};

async function createOrder(req, res) {
  const {
    service_type, pickup_lat, pickup_lng, pickup_address,
    destination_lat, destination_lng, destination_address,
    problem_type, notes,
  } = req.body;

  if (!service_type || pickup_lat == null || pickup_lng == null) {
    return res.status(400).json({ error: 'service_type, pickup_lat, pickup_lng required' });
  }

  const order = await Order.create({
    id: uuidv4(),
    client_id: req.user.id,
    service_type,
    pickup_lat:  parseFloat(pickup_lat),
    pickup_lng:  parseFloat(pickup_lng),
    pickup_address:      pickup_address || null,
    destination_lat:     destination_lat  ? parseFloat(destination_lat)  : null,
    destination_lng:     destination_lng  ? parseFloat(destination_lng)  : null,
    destination_address: destination_address || null,
    problem_type: problem_type || null,
    notes:        notes || null,
    status: 'searching',
  });

  const io = req.app.get('io');
  try {
    const provider = await matchingService.findNearestProvider(
      service_type, parseFloat(pickup_lat), parseFloat(pickup_lng));
    if (provider) {
      await order.update({
        provider_id: provider.id,
        status: 'accepted',
        accepted_at: new Date(),
      });
      if (io) io.to(`provider_${provider.id}`).emit('new_order', { orderId: order.id });
    }
  } catch (_) { /* matching failure is non-fatal */ }

  if (io) io.to(`order_${order.id}`).emit('order_update', { status: order.status });
  res.status(201).json({ order });
}

async function getOrder(req, res) {
  const order = await Order.findByPk(req.params.id);
  if (!order) return res.status(404).json({ error: 'not found' });

  const isClient   = order.client_id   === req.user.id;
  const isProvider = order.provider_id === req.user.id;
  const isAdmin    = req.user.role === 'admin';
  if (!isClient && !isProvider && !isAdmin) {
    return res.status(403).json({ error: 'forbidden' });
  }
  res.json({ order });
}

async function listMyOrders(req, res) {
  const orders = await Order.findAll({
    where: { client_id: req.user.id },
    order: [['created_at', 'DESC']],
    limit: 50,
  });
  res.json({ orders });
}

async function updateOrderStatus(req, res) {
  const { status, cancel_reason } = req.body;
  const order = await Order.findByPk(req.params.id);
  if (!order) return res.status(404).json({ error: 'not found' });

  const isClient   = order.client_id   === req.user.id;
  const isProvider = order.provider_id === req.user.id;
  const isAdmin    = req.user.role === 'admin';

  if (!isClient && !isProvider && !isAdmin) {
    return res.status(403).json({ error: 'forbidden' });
  }

  // Provider qabul qilgandan keyin bekor eta olmaydi
  if (status === 'cancelled' && isProvider && !isAdmin) {
    return res.status(403).json({
      error: 'provider_cannot_cancel',
      message: 'Qabul qilingan buyurtmani provider bekor qila olmaydi. Faqat mijoz bekor qilishi mumkin.',
    });
  }

  // Ruxsat berilgan o'tishlarni tekshirish
  const allowed = isProvider && !isAdmin
    ? (PROVIDER_TRANSITIONS[order.status] || [])
    : (VALID_TRANSITIONS[order.status] || []);

  if (!allowed.includes(status)) {
    return res.status(422).json({
      error: `cannot transition from ${order.status} to ${status}`,
    });
  }

  const updates = { status };
  if (cancel_reason) updates.cancel_reason = cancel_reason;
  if (status === 'accepted')   updates.accepted_at  = new Date();
  if (status === 'completed')  updates.completed_at = new Date();

  await order.update(updates);

  // Bekor qilinganda to'lovni qaytarish
  if (status === 'cancelled') {
    await _refundIfPaid(order.id);
  }

  const io = req.app.get('io');
  if (io) io.to(`order_${order.id}`).emit('order_update', { status });

  // Mijozga bildirishnoma (status o'zgarganda)
  if (STATUS_MESSAGES[status] && order.client_id) {
    notify(io, order.client_id, {
      type: 'order_status',
      title: STATUS_MESSAGES[status],
      body: order.service_type ? `Xizmat: ${order.service_type}` : null,
      data: { order_id: order.id, status },
    });
  }

  res.json({ order });
}

// To'lovni qaytarish (ichki funksiya)
async function _refundIfPaid(orderId) {
  try {
    const payment = await Payment.findOne({
      where: { order_id: orderId, status: 'success' },
    });
    if (payment) {
      await payment.update({ status: 'refunded' });
    }
  } catch (_) {}
}

module.exports = { createOrder, getOrder, listMyOrders, updateOrderStatus, _refundIfPaid };
