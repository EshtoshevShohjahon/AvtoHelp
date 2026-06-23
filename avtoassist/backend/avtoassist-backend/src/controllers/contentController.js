'use strict';

const SERVICES = [
  { id: 'tech_support', icon: 'build', sort: 1 },
  { id: 'tow_truck', icon: 'local_shipping', sort: 2 },
  { id: 'fuel', icon: 'local_gas_station', sort: 3 },
  { id: 'car_wash', icon: 'local_car_wash', sort: 4 },
  { id: 'parts', icon: 'settings', sort: 5 },
  { id: 'workshop', icon: 'engineering', sort: 6 },
];

async function getServices(req, res) {
  res.json(SERVICES);
}

module.exports = { getServices };
