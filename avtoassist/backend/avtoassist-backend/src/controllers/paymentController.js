'use strict';
const { Payment, Order } = require('../models');
const paymentService = require('../services/paymentService');
const { v4: uuidv4 } = require('uuid');

async function chargePayment(req, res) {
  const { order_id, method, amount } = req.body;
  if (!order_id || !method || !amount) {
    return res.status(400).json({ error: 'order_id, method, amount required' });
  }
  const order = await Order.findByPk(order_id);
  if (!order) return res.status(404).json({ error: 'order not found' });
  if (order.customer_id !== req.user.id) return res.status(403).json({ error: 'forbidden' });

  const result = await paymentService.processPayment({ method, amount, orderId: order_id });
  const payment = await Payment.create({
    id: uuidv4(),
    order_id,
    method,
    amount: parseFloat(amount),
    currency: 'UZS',
    status: result.status,
    provider_ref: result.ref || null,
  });
  if (result.status === 'completed') {
    await order.update({ payment_status: 'paid' });
  }
  res.status(201).json(payment);
}

module.exports = { chargePayment };
