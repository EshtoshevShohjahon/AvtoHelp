'use strict';
require('dotenv').config();
const { sequelize, PartsStore, Workshop, WorkshopService } = require('./src/models');
const { v4: uuidv4 } = require('uuid');

async function seed() {
  await sequelize.sync({ alter: true });

  const storeId = uuidv4();
  await PartsStore.upsert({
    id: storeId,
    name: 'AvtoZapchast Toshkent',
    address: 'Yunusobod tumani, Toshkent',
    phone: '+998901234567',
    lat: 41.3275,
    lon: 69.2401,
    is_active: true,
  });
  console.log('Seeded parts store:', storeId);

  const workshopId = uuidv4();
  await Workshop.upsert({
    id: workshopId,
    name: 'Master Avto Servis',
    address: 'Chilonzor tumani, Toshkent',
    phone: '+998901112233',
    lat: 41.2995,
    lon: 69.2401,
    rating_avg: 4.7,
    rating_count: 32,
    is_active: true,
  });
  await WorkshopService.upsert({ id: uuidv4(), workshop_id: workshopId, name: 'Dvigatelni ta\'mirlash', price_from: 200000 });
  await WorkshopService.upsert({ id: uuidv4(), workshop_id: workshopId, name: 'Moy almashtirish', price_from: 50000 });
  console.log('Seeded workshop:', workshopId);

  await sequelize.close();
  console.log('Seed complete.');
}

seed().catch(err => { console.error(err); process.exit(1); });
