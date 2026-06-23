'use strict';
const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Listing = sequelize.define('Listing', {
  id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
  provider_id: { type: DataTypes.UUID, allowNull: false },
  listing_type: {
    type: DataTypes.ENUM('service', 'part', 'oil', 'tire', 'other'),
    allowNull: false,
    defaultValue: 'service',
  },
  title: { type: DataTypes.STRING, allowNull: false },
  description: { type: DataTypes.TEXT, allowNull: true },
  price: { type: DataTypes.DECIMAL(12, 0), allowNull: false },
  price_unit: { type: DataTypes.STRING, allowNull: true, defaultValue: 'so\'m' },
  // 'negotiable' if price is indicative
  price_type: {
    type: DataTypes.ENUM('fixed', 'from', 'negotiable'),
    allowNull: false,
    defaultValue: 'fixed',
  },
  category: { type: DataTypes.STRING, allowNull: true },
  vehicle_category: {
    type: DataTypes.ENUM('light', 'truck', 'both'),
    allowNull: false,
    defaultValue: 'both',
  },
  images: {
    type: DataTypes.JSON,
    allowNull: false,
    defaultValue: [],
  },
  is_active: { type: DataTypes.BOOLEAN, allowNull: false, defaultValue: true },
  views: { type: DataTypes.INTEGER, allowNull: false, defaultValue: 0 },
}, {
  tableName: 'listings',
  timestamps: true,
  underscored: true,
});

module.exports = Listing;
