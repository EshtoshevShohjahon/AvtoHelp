const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const User = sequelize.define('User', {
  id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
  phone: { type: DataTypes.STRING, allowNull: false, unique: true },
  full_name: { type: DataTypes.STRING, allowNull: true },
  role: {
    type: DataTypes.ENUM('client', 'provider', 'admin'),
    allowNull: false,
    defaultValue: 'client',
  },
  preferred_language: {
    type: DataTypes.ENUM('uz', 'uz-cyrl', 'ru', 'en'),
    allowNull: false,
    defaultValue: 'uz',
  },
}, {
  tableName: 'users',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at',
});

module.exports = User;
