const { Provider } = require('../models');
const { haversineDistanceKm } = require('../utils/haversine');
const { Op } = require('sequelize');

const RADIUS_STEPS_KM = [5, 10, 15];

async function findNearestProvider({ serviceType, lat, lng, excludeUserIds = [] }) {
  const where = {
    service_type: serviceType,
    status: 'online',
    // is_verified hozircha talab qilinmaydi — KYC oqimi ulanmagan; tasdiq
    // alohida ishonch belgisi sifatida ko'rsatiladi (statistikada)
    current_lat: { [Op.ne]: null },
    current_lng: { [Op.ne]: null },
  };
  // Rad etgan ustalarni qayta taklif qilmaymiz
  if (excludeUserIds.length) {
    where.user_id = { [Op.notIn]: excludeUserIds };
  }
  const candidates = await Provider.findAll({ where });

  for (const radiusKm of RADIUS_STEPS_KM) {
    let nearest = null;
    let nearestDistance = Infinity;

    for (const provider of candidates) {
      const distance = haversineDistanceKm(lat, lng, provider.current_lat, provider.current_lng);
      if (distance <= radiusKm && distance < nearestDistance) {
        nearest = provider;
        nearestDistance = distance;
      }
    }

    if (nearest) {
      return { provider: nearest, distanceKm: Number(nearestDistance.toFixed(2)), radiusUsedKm: radiusKm };
    }
  }

  return { provider: null, distanceKm: null, radiusUsedKm: RADIUS_STEPS_KM[RADIUS_STEPS_KM.length - 1] };
}

module.exports = { findNearestProvider, RADIUS_STEPS_KM };
