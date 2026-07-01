'use strict';
const { Op } = require('sequelize');
const { Order, Provider, User } = require('../models');
const { Payment } = require('../models/Payment');
const matchingService = require('../services/matchingService');
const { notify } = require('../services/notificationService');
const { requiresKyc } = require('../utils/kyc');
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
    // matchingService obyekt argument kutadi va { provider } qaytaradi
    const { provider } = await matchingService.findNearestProvider({
      serviceType: service_type,
      lat: parseFloat(pickup_lat),
      lng: parseFloat(pickup_lng),
    });
    if (provider) {
      // Buyurtma ustaga TAKLIF qilinadi (avtomatik qabul qilinmaydi).
      // provider_id sifatida ustaning user.id'sini saqlaymiz — auth tekshiruvi
      // va bildirishnoma xonalari (user_<id>) shunga tayanadi. Status 'searching'
      // qoladi: usta qabul qilsa 'accepted' bo'ladi, rad etsa keyingisiga o'tadi.
      await order.update({ provider_id: provider.user_id });
      if (io) io.to(`user_${provider.user_id}`).emit('new_order', { orderId: order.id });
      notify(io, provider.user_id, {
        type: 'new_order',
        title: 'Yangi buyurtma',
        body: pickup_address || `Xizmat: ${service_type}`,
        data: { order_id: order.id },
      });
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

// GET /api/providers/orders — ustaga biriktirilgan buyurtmalar
async function listProviderOrders(req, res) {
  const provider = await Provider.findOne({ where: { user_id: req.user.id } });
  const ids = provider ? [req.user.id, provider.id] : [req.user.id];
  const orders = await Order.findAll({
    where: { provider_id: { [Op.in]: ids } },
    include: [{ model: User, as: 'client', attributes: ['full_name', 'phone'] }],
    order: [['created_at', 'DESC']],
    limit: 50,
  });
  res.json({
    orders: orders.map((o) => {
      const obj = o.toJSON();
      obj.client_name = obj.client ? obj.client.full_name : '';
      obj.client_phone = obj.client ? obj.client.phone : '';
      delete obj.client;
      return obj;
    }),
  });
}

// POST /api/orders/:id/decline — usta taklif qilingan buyurtmani rad etadi;
// buyurtma keyingi eng yaqin ustaga taklif qilinadi (rad etganni chiqarib).
async function declineOrder(req, res) {
  const order = await Order.findByPk(req.params.id);
  if (!order) return res.status(404).json({ error: 'not found' });
  if (order.provider_id !== req.user.id) {
    return res.status(403).json({ error: 'forbidden' });
  }
  if (order.status !== 'searching') {
    return res.status(422).json({ error: 'order_already_taken' });
  }

  const io = req.app.get('io');
  // Keyingi ustani topamiz (rad etganni chiqarib)
  let nextProvider = null;
  try {
    const result = await matchingService.findNearestProvider({
      serviceType: order.service_type,
      lat: order.pickup_lat,
      lng: order.pickup_lng,
      excludeUserIds: [req.user.id],
    });
    nextProvider = result.provider;
  } catch (_) { /* non-fatal */ }

  if (nextProvider) {
    await order.update({ provider_id: nextProvider.user_id });
    if (io) io.to(`user_${nextProvider.user_id}`).emit('new_order', { orderId: order.id });
    notify(io, nextProvider.user_id, {
      type: 'new_order',
      title: 'Yangi buyurtma',
      body: order.pickup_address || `Xizmat: ${order.service_type}`,
      data: { order_id: order.id },
    });
  } else {
    // Boshqa usta yo'q — buyurtma bo'sh holatda qoladi (mijoz kutadi/bekor qiladi)
    await order.update({ provider_id: null });
  }

  res.json({ ok: true, reassigned: Boolean(nextProvider) });
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

  // Buyurtmani qabul qilish — mijoz bilan ishlaydigan sektorlar uchun KYC majburiy
  if (status === 'accepted' && isProvider && !isAdmin) {
    const provider = await Provider.findOne({ where: { user_id: req.user.id } });
    if (provider && requiresKyc(provider.sector) && !provider.is_verified) {
      return res.status(403).json({ error: 'verification_required' });
    }
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

module.exports = { createOrder, getOrder, listMyOrders, listProviderOrders, declineOrder, updateOrderStatus, _refundIfPaid };
