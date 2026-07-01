const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const ProviderReview = sequelize.define('ProviderReview', {
  id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
  provider_id: { type: DataTypes.UUID, allowNull: false },
  user_id: { type: DataTypes.UUID, allowNull: false },
  rating: {
    type: DataTypes.INTEGER,
    allowNull: false,
    validate: { min: 1, max: 5 },
  },
  comment: { type: DataTypes.TEXT, allowNull: true },
}, {
  tableName: 'provider_reviews',
  timestamps: true,
  underscored: true,
  indexes: [
    { unique: true, fields: ['provider_id', 'user_id'] },
  ],
});

module.exports = ProviderReview;
