const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Order = sequelize.define('Order', {
  id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
  client_id: { type: DataTypes.UUID, allowNull: false },
  provider_id: { type: DataTypes.UUID, allowNull: true },
  service_type: {
    type: DataTypes.ENUM('tech_support', 'fuel', 'car_wash', 'tow_truck'),
    allowNull: false,
  },
  status: {
    type: DataTypes.ENUM('searching', 'accepted', 'en_route', 'in_progress', 'completed', 'cancelled'),
    allowNull: false,
    defaultValue: 'searching',
  },
  problem_type: { type: DataTypes.STRING, allowNull: true },
  pickup_lat: { type: DataTypes.FLOAT, allowNull: false },
  pickup_lng: { type: DataTypes.FLOAT, allowNull: false },
  pickup_address: { type: DataTypes.STRING, allowNull: true },
  destination_lat: { type: DataTypes.FLOAT, allowNull: true },
  destination_lng: { type: DataTypes.FLOAT, allowNull: true },
  destination_address: { type: DataTypes.STRING, allowNull: true },
  price: { type: DataTypes.FLOAT, allowNull: true },
  cancel_reason: { type: DataTypes.STRING, allowNull: true },
  completed_at: { type: DataTypes.DATE, allowNull: true },
}, {
  tableName: 'orders',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at',
});

module.exports = Order;
