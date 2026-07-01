'use strict';
const { Notification } = require('../models');

// Bildirishnoma yaratadi va (mavjud bo'lsa) socket orqali real-time yuboradi.
// io — Express app dan olinadi: req.app.get('io')
async function notify(io, userId, { type = 'general', title, body, data = {} }) {
  if (!userId || !title) return null;
  try {
    const n = await Notification.create({
      user_id: userId, type, title, body: body || null, data,
    });
    if (io) {
      io.to(`user_${userId}`).emit('notification', {
        id: n.id, type, title, body, data, created_at: n.created_at,
      });
    }
    return n;
  } catch (_) {
    return null; // bildirishnoma xatosi asosiy oqimni buzmasin
  }
}

module.exports = { notify };
