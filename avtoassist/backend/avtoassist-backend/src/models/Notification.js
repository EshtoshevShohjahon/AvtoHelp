const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Notification = sequelize.define('Notification', {
  id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
  user_id: { type: DataTypes.UUID, allowNull: false },
  type: { type: DataTypes.STRING, allowNull: false, defaultValue: 'general' },
  title: { type: DataTypes.STRING, allowNull: false },
  body: { type: DataTypes.TEXT, allowNull: true },
  data: { type: DataTypes.JSON, defaultValue: {} },
  is_read: { type: DataTypes.BOOLEAN, allowNull: false, defaultValue: false },
}, {
  tableName: 'notifications',
  timestamps: true,
  underscored: true,
  indexes: [{ fields: ['user_id', 'is_read'] }],
});

module.exports = Notification;
