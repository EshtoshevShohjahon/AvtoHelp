const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Favorite = sequelize.define('Favorite', {
  id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
  user_id: { type: DataTypes.UUID, allowNull: false },
  listing_id: { type: DataTypes.UUID, allowNull: false },
}, {
  tableName: 'favorites',
  timestamps: true,
  underscored: true,
  indexes: [
    { unique: true, fields: ['user_id', 'listing_id'] },
  ],
});

module.exports = Favorite;
