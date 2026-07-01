const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Workshop = sequelize.define('Workshop', {
  id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
  owner_id: { type: DataTypes.UUID, allowNull: true },
  name: { type: DataTypes.STRING, allowNull: false },
  address: { type: DataTypes.STRING, allowNull: true },
  lat: { type: DataTypes.FLOAT, allowNull: false },
  lng: { type: DataTypes.FLOAT, allowNull: false },
  specializations: { type: DataTypes.JSON, allowNull: true },
  rating_avg: { type: DataTypes.FLOAT, allowNull: false, defaultValue: 0 },
  rating_count: { type: DataTypes.INTEGER, allowNull: false, defaultValue: 0 },
  working_hours: { type: DataTypes.JSON, allowNull: true },
  is_active: { type: DataTypes.BOOLEAN, allowNull: false, defaultValue: true },
  vehicle_category: {
    type: DataTypes.ENUM('light', 'truck', 'both'),
    allowNull: false,
    defaultValue: 'light',
  },
  osm_id: { type: DataTypes.STRING, allowNull: true, unique: true },
  phone: { type: DataTypes.STRING, allowNull: true },
  website: { type: DataTypes.STRING, allowNull: true },
}, {
  tableName: 'workshops',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: false,
});

const WorkshopService = sequelize.define('WorkshopService', {
  id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
  workshop_id: { type: DataTypes.UUID, allowNull: false },
  service_name: { type: DataTypes.STRING, allowNull: false },
  price_from: { type: DataTypes.FLOAT, allowNull: false },
}, {
  tableName: 'workshop_services',
  timestamps: false,
});

module.exports = { Workshop, WorkshopService };
