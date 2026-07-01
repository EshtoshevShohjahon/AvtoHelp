'use strict';

// KYC hozircha O'CHIRILGAN — hech qaysi sektorga majburiy emas.
// Keyinroq yoqish uchun shu ro'yxatga sektorlarni qaytaring, masalan:
//   ['workshop', 'car_wash', 'tow_truck', 'tech_support']
const KYC_REQUIRED_SECTORS = [];

function requiresKyc(sector) {
  return KYC_REQUIRED_SECTORS.includes(sector);
}

module.exports = { KYC_REQUIRED_SECTORS, requiresKyc };
