'use strict';
const { Op } = require('sequelize');
const { Order } = require('../models');
const { _refundIfPaid } = require('../controllers/orderController');

const TIMEOUT_MINUTES = 30;
const CHECK_INTERVAL_MS = 60 * 1000;

function start(io) {
  setInterval(async () => {
    try {
      const cutoff = new Date(Date.now() - TIMEOUT_MINUTES * 60 * 1000);
      const timedOut = await Order.findAll({
        where: {
          status: 'accepted',
          accepted_at: { [Op.lt]: cutoff },
        },
      });

      for (const order of timedOut) {
        await order.update({
          status: 'cancelled',
          cancel_reason: 'auto_timeout',
        });
        await _refundIfPaid(order.id);
        if (io) io.to(`order_${order.id}`).emit('order_update', { status: 'cancelled', reason: 'auto_timeout' });
        console.log(`⏱ Order ${order.id} auto-cancelled (provider did not arrive in ${TIMEOUT_MINUTES} min)`);
      }
    } catch (err) {
      console.error('orderTimeoutService error:', err);
    }
  }, CHECK_INTERVAL_MS);

  console.log(`✅ Order timeout service started (checks every ${CHECK_INTERVAL_MS / 1000}s, timeout=${TIMEOUT_MINUTES}min)`);
}

module.exports = { start };
