'use strict';
const { Notification } = require('../models');

// GET /notifications
async function list(req, res) {
  const rows = await Notification.findAll({
    where: { user_id: req.user.id },
    order: [['created_at', 'DESC']],
    limit: 50,
  });
  res.json({ notifications: rows });
}

// GET /notifications/unread-count
async function unreadCount(req, res) {
  const count = await Notification.count({
    where: { user_id: req.user.id, is_read: false },
  });
  res.json({ count });
}

// POST /notifications/read-all
async function markAllRead(req, res) {
  await Notification.update(
    { is_read: true },
    { where: { user_id: req.user.id, is_read: false } },
  );
  res.json({ ok: true });
}

module.exports = { list, unreadCount, markAllRead };
