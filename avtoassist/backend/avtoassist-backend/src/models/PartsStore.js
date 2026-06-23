const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const PartsStore = sequelize.define('PartsStore', {
  id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
  owner_id: { type: DataTypes.UUID, allowNull: false },
  name: { type: DataTypes.STRING, allowNull: false },
  address: { type: DataTypes.STRING, allowNull: true },
  lat: { type: DataTypes.FLOAT, allowNull: false },
  lng: { type: DataTypes.FLOAT, allowNull: false },
  working_hours: { type: DataTypes.JSON, allowNull: true },
  is_active: { type: DataTypes.BOOLEAN, allowNull: false, defaultValue: true },
}, {
  tableName: 'parts_stores',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: false,
});

const PartsInventory = sequelize.define('PartsInventory', {
  id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
  store_id: { type: DataTypes.UUID, allowNull: false },
  part_name: { type: DataTypes.STRING, allowNull: false },
  price: { type: DataTypes.FLOAT, allowNull: false },
  stock_qty: { type: DataTypes.INTEGER, allowNull: false, defaultValue: 0 },
  car_compatibility: { type: DataTypes.JSON, allowNull: true },
}, {
  tableName: 'parts_inventory',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: false,
});

module.exports = { PartsStore, PartsInventory };
