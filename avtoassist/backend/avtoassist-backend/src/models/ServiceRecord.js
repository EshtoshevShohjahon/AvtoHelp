const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const ServiceRecord = sequelize.define('ServiceRecord', {
  id:            { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
  vehicle_id:    { type: DataTypes.UUID, allowNull: false },
  service_type:  {
    type: DataTypes.ENUM('oil_change','inspection','tire','brake','engine','battery','transmission','other'),
    allowNull: false,
    defaultValue: 'other',
  },
  service_date:  { type: DataTypes.DATEONLY, allowNull: false },
  odometer_km:   { type: DataTypes.INTEGER, allowNull: false },
  workshop_name: { type: DataTypes.STRING, allowNull: true },
  mechanic_name: { type: DataTypes.STRING, allowNull: true },
  cost:          { type: DataTypes.DECIMAL(12, 2), allowNull: true },
  notes:         { type: DataTypes.TEXT, allowNull: true },
  next_service_km: { type: DataTypes.INTEGER, allowNull: true },
  added_by_provider_id: { type: DataTypes.UUID, allowNull: true },
}, {
  tableName: 'service_records',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: false,
});

module.exports = ServiceRecord;
