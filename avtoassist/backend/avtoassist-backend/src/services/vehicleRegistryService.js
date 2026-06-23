'use strict';
const crypto = require('crypto');

// Davlat avtomobil reestri simulyatsiyasi.
// Tex passport (texnik passport) raqami bo'yicha avtomobil ma'lumotlarini qaytaradi.
// Production'da bu tashqi reestr API'siga ulanadi (GAI / "Avtoyo'l").

// Oldindan ro'yxatga olingan namuna yozuvlari
const REGISTRY = {
  'AAF1234567': { brand: 'Chevrolet', model: 'Cobalt', year: 2021, color: 'Oq', plate_number: '01A123BC' },
  'AAF7654321': { brand: 'Chevrolet', model: 'Nexia 3', year: 2019, color: 'Kumush', plate_number: '01B456DE' },
  'AAG1112223': { brand: 'Chevrolet', model: 'Malibu 2', year: 2022, color: 'Qora', plate_number: '01C789FG' },
  'AAG9998887': { brand: 'Chevrolet', model: 'Spark', year: 2018, color: 'Qizil', plate_number: '01D321HI' },
  'AAH5556667': { brand: 'Kia', model: 'K5', year: 2023, color: 'Oq', plate_number: '01E654JK' },
};

const BRANDS = [
  { brand: 'Chevrolet', models: ['Cobalt', 'Nexia 3', 'Gentra', 'Spark', 'Malibu 2', 'Tracker'] },
  { brand: 'Kia', models: ['K5', 'Sportage', 'Sorento'] },
  { brand: 'Hyundai', models: ['Sonata', 'Elantra', 'Tucson'] },
  { brand: 'Toyota', models: ['Camry', 'Corolla', 'RAV4'] },
];
const COLORS = ['Oq', 'Qora', 'Kumush', 'Kulrang', 'Qizil', 'Koʻk'];

/**
 * Tex passport raqami bo'yicha avtomobil ma'lumotlarini "reestrdan" yuklab oladi.
 * Topilmasa, raqamdan deterministik tarzda hosil qiladi (demo uchun).
 * @param {string} techPassport
 * @returns {object|null}
 */
function lookupByTechPassport(techPassport) {
  if (!techPassport) return null;
  const key = String(techPassport).toUpperCase().replace(/\s+/g, '');

  // Format tekshiruvi: 2-3 harf + 7 raqam
  if (!/^[A-Z]{2,3}\d{7}$/.test(key)) return null;

  if (REGISTRY[key]) {
    return { tech_passport: key, ...REGISTRY[key] };
  }

  // Deterministik fallback (har doim bir xil natija beradi)
  const hash = crypto.createHash('sha256').update(key).digest();
  const b = BRANDS[hash[0] % BRANDS.length];
  const model = b.models[hash[1] % b.models.length];
  const year = 2010 + (hash[2] % 15);
  const color = COLORS[hash[3] % COLORS.length];
  const region = String((hash[4] % 90) + 10).padStart(2, '0');
  const letter1 = String.fromCharCode(65 + (hash[5] % 26));
  const digits = String((hash[6] << 8 | hash[7]) % 1000).padStart(3, '0');
  const letter2 = String.fromCharCode(65 + (hash[8] % 26));
  const letter3 = String.fromCharCode(65 + (hash[9] % 26));

  return {
    tech_passport: key,
    brand: b.brand,
    model,
    year,
    color,
    plate_number: `${region}${letter1}${digits}${letter2}${letter3}`,
  };
}

module.exports = { lookupByTechPassport };
