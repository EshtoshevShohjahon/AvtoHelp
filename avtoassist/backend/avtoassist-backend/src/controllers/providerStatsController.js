'use strict';
const { Op } = require('sequelize');
const { Provider, ServiceRecord, Vehicle, Order, User } = require('../models');
const { asyncHandler } = require('../middleware/errorHandler');

// Berilgan usta (user) uchun xizmat statistikasini yig'adi.
// added_by_provider_id ServiceRecord'da user.id'ni saqlaydi.
async function collect(userId, providerId) {
  const records = await ServiceRecord.findAll({
    where: { added_by_provider_id: userId },
    include: [{ model: Vehicle, attributes: ['id', 'brand', 'model', 'year', 'plate_number'] }],
    order: [['service_date', 'DESC'], ['created_at', 'DESC']],
  });

  // Xizmat turlari bo'yicha taqsimot + xizmat ko'rsatilgan avtomobillar
  const breakdown = {};
  const vehicleIds = new Set();
  for (const r of records) {
    breakdown[r.service_type] = (breakdown[r.service_type] || 0) + 1;
    vehicleIds.add(r.vehicle_id);
  }

  // Buyurtmalar — provider_id ikki konventsiyada saqlanishi mumkin (Provider.id yoki user.id)
  const ids = providerId ? [providerId, userId] : [userId];
  const completed = await Order.findAll({
    where: { provider_id: { [Op.in]: ids }, status: 'completed' },
    attributes: ['id', 'price', 'completed_at'],
  });
  const startOfToday = new Date();
  startOfToday.setHours(0, 0, 0, 0);
  const totalEarnings = completed.reduce((s, o) => s + (o.price || 0), 0);
  const todayEarnings = completed
    .filter((o) => o.completed_at && new Date(o.completed_at) >= startOfToday)
    .reduce((s, o) => s + (o.price || 0), 0);

  return {
    records,
    breakdown,
    vehicleCount: vehicleIds.size,
    totalServices: records.length,
    completedOrders: completed.length,
    totalEarnings,
    todayEarnings,
  };
}

// GET /api/providers/me/stats — ustaning o'z paneli uchun (to'liq, plate bilan)
const getMyStats = asyncHandler(async (req, res) => {
  const provider = await Provider.findOne({ where: { user_id: req.user.id } });
  const s = await collect(req.user.id, provider ? provider.id : null);

  const recent = s.records.slice(0, 20).map((r) => {
    const v = r.Vehicle || {};
    return {
      vehicle: [v.brand, v.model].filter(Boolean).join(' ') || '—',
      plate: v.plate_number || null,
      year: v.year || null,
      service_type: r.service_type,
      service_date: r.service_date,
      odometer_km: r.odometer_km,
    };
  });

  res.json({
    today_earnings: s.todayEarnings,
    total_earnings: s.totalEarnings,
    total_orders: s.completedOrders,
    rating: provider ? provider.rating_avg : 0,
    rating_count: provider ? provider.rating_count : 0,
    is_online: provider ? provider.status === 'online' : false,
    serviced_vehicles_count: s.vehicleCount,
    total_services: s.totalServices,
    service_breakdown: s.breakdown,
    recent_services: recent,
  });
});

// GET /api/providers/:id/stats — mijoz ustani tanlashdan oldin ko'rishi uchun (ommaviy, plate yashirin)
const getPublicStats = asyncHandler(async (req, res) => {
  const provider = await Provider.findByPk(req.params.id, {
    include: [{ model: User, attributes: ['full_name', 'phone'] }],
  });
  if (!provider) return res.status(404).json({ error: 'provider not found' });

  const s = await collect(provider.user_id, provider.id);

  // Ommaviy ko'rinishda davlat raqami va narx ko'rsatilmaydi (maxfiylik)
  const recent = s.records.slice(0, 15).map((r) => {
    const v = r.Vehicle || {};
    return {
      vehicle: [v.brand, v.model].filter(Boolean).join(' ') || '—',
      year: v.year || null,
      service_type: r.service_type,
      service_date: r.service_date,
    };
  });

  res.json({
    provider: {
      id: provider.id,
      name: provider.User ? provider.User.full_name : '',
      sector: provider.sector || null,
      rating: provider.rating_avg,
      rating_count: provider.rating_count,
      is_verified: provider.is_verified,
      is_online: provider.status === 'online',
    },
    total_services: s.totalServices,
    serviced_vehicles_count: s.vehicleCount,
    completed_orders: s.completedOrders,
    service_breakdown: s.breakdown,
    recent_services: recent,
  });
});

module.exports = { getMyStats, getPublicStats };
