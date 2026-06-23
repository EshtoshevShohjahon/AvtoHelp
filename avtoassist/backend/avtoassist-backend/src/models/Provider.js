const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Provider = sequelize.define('Provider', {
  id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
  user_id: { type: DataTypes.UUID, allowNull: false, unique: true },
  service_type: {
    type: DataTypes.ENUM('tech_support', 'fuel', 'car_wash', 'tow_truck'),
    allowNull: true,
  },
  sector: {
    type: DataTypes.ENUM(
      'workshop', 'parts_store', 'tire_shop', 'oil_store',
      'car_wash', 'tow_truck', 'tech_support'
    ),
    allowNull: true,
  },
  status: {
    type: DataTypes.ENUM('online', 'offline', 'busy'),
    allowNull: false,
    defaultValue: 'offline',
  },
  current_lat: { type: DataTypes.FLOAT, allowNull: true },
  current_lng: { type: DataTypes.FLOAT, allowNull: true },
  rating_avg: { type: DataTypes.FLOAT, allowNull: false, defaultValue: 0 },
  rating_count: { type: DataTypes.INTEGER, allowNull: false, defaultValue: 0 },
  is_verified: { type: DataTypes.BOOLEAN, allowNull: false, defaultValue: false },
  kyc_status: {
    type: DataTypes.ENUM('pending', 'auto_approved', 'auto_rejected', 'appeal_review'),
    allowNull: false,
    defaultValue: 'pending',
  },
  kyc_reject_reason: { type: DataTypes.STRING, allowNull: true },
  kyc_checked_at: { type: DataTypes.DATE, allowNull: true },
  document_number_hash: { type: DataTypes.STRING, allowNull: true },
}, {
  tableName: 'providers',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at',
});

module.exports = Provider;
