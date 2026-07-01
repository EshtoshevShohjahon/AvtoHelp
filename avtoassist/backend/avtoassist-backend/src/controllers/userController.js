const { Vehicle, Provider } = require('../models');
const { asyncHandler } = require('../middleware/errorHandler');
const { lookupByTechPassport } = require('../services/vehicleRegistryService');

const getMe = asyncHandler(async (req, res) => {
  res.json({ user: req.user });
});

const updateMe = asyncHandler(async (req, res) => {
  const { full_name, preferred_language, role, avatar_url, sector } = req.body;
  if (full_name !== undefined) req.user.full_name = full_name;
  if (preferred_language !== undefined) req.user.preferred_language = preferred_language;
  if (role !== undefined && ['client', 'provider'].includes(role)) req.user.role = role;
  if (avatar_url !== undefined) req.user.avatar_url = avatar_url;
  await req.user.save();

  // Provider ro'yxatdan o'tganda Provider record yarating.
  // Yo'l xizmatlari (buyurtma orqali ishlaydigan) sektorlarni service_type'ga
  // moslaymiz — matching service_type bo'yicha qidiradi.
  if (role === 'provider') {
    const sectorToServiceType = {
      car_wash: 'car_wash',
      tow_truck: 'tow_truck',
      tech_support: 'tech_support',
    };
    const serviceType = sector ? (sectorToServiceType[sector] || null) : null;
    const existing = await Provider.findOne({ where: { user_id: req.user.id } });
    if (!existing) {
      await Provider.create({
        user_id: req.user.id,
        sector: sector || null,
        service_type: serviceType,
      });
    } else if (sector) {
      await existing.update({ sector, service_type: serviceType });
    }
  }

  res.json({ user: req.user });
});

const listVehicles = asyncHandler(async (req, res) => {
  const vehicles = await Vehicle.findAll({ where: { user_id: req.user.id } });
  res.json({ vehicles });
});

// GET /api/users/me/vehicles/lookup?tech_passport=AAF1234567
// Tex passport raqami bo'yicha avtomobil ma'lumotlarini reestrdan yuklab oladi
const lookupVehicle = asyncHandler(async (req, res) => {
  const techPassport = req.query.tech_passport;
  if (!techPassport) {
    return res.status(400).json({ error: req.t('validation_error') });
  }
  const data = lookupByTechPassport(techPassport);
  if (!data) {
    return res.status(404).json({ error: req.t('user_not_found') });
  }
  res.json({ vehicle: data });
});

const createVehicle = asyncHandler(async (req, res) => {
  let { tech_passport, brand, model, plate_number, year, color, vin } = req.body;
  if (!tech_passport) {
    return res.status(400).json({ error: req.t('validation_error') });
  }

  // Mijoz faqat tex passport yuborsa — qolgan maydonlarni reestrdan to'ldiramiz
  if (!brand || !model || !plate_number) {
    const data = lookupByTechPassport(tech_passport);
    if (!data) {
      return res.status(404).json({ error: req.t('user_not_found') });
    }
    brand = brand || data.brand;
    model = model || data.model;
    plate_number = plate_number || data.plate_number;
    year = year || data.year;
    color = color || data.color;
  }

  const vehicle = await Vehicle.create({
    user_id: req.user.id,
    tech_passport: String(tech_passport).toUpperCase().replace(/\s+/g, ''),
    brand,
    model,
    plate_number,
    year,
    color,
    vin,
  });
  res.status(201).json({ vehicle });
});

const deleteVehicle = asyncHandler(async (req, res) => {
  const vehicle = await Vehicle.findOne({ where: { id: req.params.id, user_id: req.user.id } });
  if (!vehicle) return res.status(404).json({ error: req.t('user_not_found') });
  await vehicle.destroy();
  res.json({ ok: true });
});

module.exports = { getMe, updateMe, listVehicles, lookupVehicle, createVehicle, deleteVehicle };
