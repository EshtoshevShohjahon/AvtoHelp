'use strict';

// KYC (tasdiqlash) majburiy bo'lgan sektorlar — mijoz bilan bevosita ishlaydigan
// xizmat ko'rsatuvchilar. Sof sotuvchi do'konlar (parts_store, tire_shop,
// oil_store) uchun KYC ixtiyoriy.
const KYC_REQUIRED_SECTORS = ['workshop', 'car_wash', 'tow_truck', 'tech_support'];

function requiresKyc(sector) {
  return KYC_REQUIRED_SECTORS.includes(sector);
}

module.exports = { KYC_REQUIRED_SECTORS, requiresKyc };
