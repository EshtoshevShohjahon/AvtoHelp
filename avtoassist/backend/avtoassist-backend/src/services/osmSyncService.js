'use strict';
/**
 * Overpass API orqali Uzbekiston avto servislarini Workshop jadvaliga yuklaydi.
 * GET /api/admin/sync-workshops  (admin token talab qilinadi)
 *
 * Har safar chaqirilganda yangi node'larni qo'shadi, mavjudlarini yangilaydi
 * (osm_id orqali upsert).
 */
const { Workshop } = require('../models');
const { v4: uuidv4 } = require('uuid');

// Overpass QL — Uzbekiston ichidagi avto ta'mirlash, moyka va shina xizmatlar
const OVERPASS_QUERY = `
[out:json][timeout:90];
area["ISO3166-1"="UZ"][admin_level=2]->.uz;
(
  node["shop"="car_repair"](area.uz);
  node["amenity"="car_wash"](area.uz);
  node["shop"="tyres"](area.uz);
  node["shop"="car_parts"](area.uz);
  node["amenity"="fuel"](area.uz);
);
out body;
`.trim();

async function syncWorkshopsFromOSM() {
  const response = await fetch('https://overpass-api.de/api/interpreter', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: `data=${encodeURIComponent(OVERPASS_QUERY)}`,
    signal: AbortSignal.timeout(100_000),
  });
  if (!response.ok) throw new Error(`Overpass HTTP ${response.status}`);
  const json = await response.json();

  const elements = (json.elements || []).filter(
    e => e.type === 'node' && e.lat && e.lon
  );

  let created = 0, updated = 0;

  for (const el of elements) {
    const tags = el.tags || {};
    const name =
      tags['name:uz'] || tags['name:ru'] || tags.name || 'Avto servis';

    const type = tags.shop === 'car_repair' ? 'Ta\'mirlash'
      : tags.amenity === 'car_wash' ? 'Moyka'
      : tags.shop === 'tyres' ? 'Shina'
      : tags.shop === 'car_parts' ? 'Ehtiyot qismlar'
      : tags.amenity === 'fuel' ? 'Yoqilg\'i'
      : 'Avto servis';

    const existing = await Workshop.findOne({ where: { osm_id: String(el.id) } });
    const data = {
      name,
      address: tags['addr:street']
        ? `${tags['addr:street']} ${tags['addr:housenumber'] || ''}`.trim()
        : tags.address || null,
      lat: el.lat,
      lng: el.lon,
      osm_id: String(el.id),
      specializations: [type],
      phone: tags.phone || tags['contact:phone'] || null,
      website: tags.website || tags['contact:website'] || null,
      is_active: true,
    };

    if (existing) {
      await existing.update(data);
      updated++;
    } else {
      await Workshop.create({ id: uuidv4(), owner_id: null, ...data });
      created++;
    }
  }

  return { total: elements.length, created, updated };
}

module.exports = { syncWorkshopsFromOSM };
