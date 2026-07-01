const sequelize = require('../config/database');
const User = require('./User');
const Vehicle = require('./Vehicle');
const Provider = require('./Provider');
const Order = require('./Order');
const { PartsStore, PartsInventory } = require('./PartsStore');
const { Workshop, WorkshopService } = require('./Workshop');
const { Payment, Review, OtpCode, RefreshToken } = require('./Payment');
const ServiceRecord = require('./ServiceRecord');
const Listing = require('./Listing');
const Favorite = require('./Favorite');
const ProviderReview = require('./ProviderReview');
const Notification = require('./Notification');

User.hasMany(Vehicle, { foreignKey: 'user_id' });
Vehicle.belongsTo(User, { foreignKey: 'user_id' });
Vehicle.hasMany(ServiceRecord, { foreignKey: 'vehicle_id', as: 'serviceRecords' });
ServiceRecord.belongsTo(Vehicle, { foreignKey: 'vehicle_id' });

User.hasOne(Provider, { foreignKey: 'user_id' });
Provider.belongsTo(User, { foreignKey: 'user_id' });

User.hasMany(RefreshToken, { foreignKey: 'user_id' });

User.hasMany(Order, { foreignKey: 'client_id', as: 'clientOrders' });
Order.belongsTo(User, { foreignKey: 'client_id', as: 'client' });

Provider.hasMany(Order, { foreignKey: 'provider_id' });
Order.belongsTo(Provider, { foreignKey: 'provider_id', as: 'provider' });

User.hasMany(PartsStore, { foreignKey: 'owner_id' });
PartsStore.hasMany(PartsInventory, { foreignKey: 'store_id', as: 'inventory' });
PartsInventory.belongsTo(PartsStore, { foreignKey: 'store_id' });

User.hasMany(Workshop, { foreignKey: 'owner_id' });
Workshop.hasMany(WorkshopService, { foreignKey: 'workshop_id', as: 'services' });
WorkshopService.belongsTo(Workshop, { foreignKey: 'workshop_id' });

Order.hasOne(Payment, { foreignKey: 'order_id' });
Payment.belongsTo(Order, { foreignKey: 'order_id' });

Order.hasOne(Review, { foreignKey: 'order_id' });
Review.belongsTo(Order, { foreignKey: 'order_id' });

// Listing belongs to Provider (via user_id on provider)
Provider.hasMany(Listing, { foreignKey: 'provider_id', as: 'listings' });
Listing.belongsTo(Provider, { foreignKey: 'provider_id', as: 'provider' });

// Favorites — mijoz e'lonni saqlaydi
User.hasMany(Favorite, { foreignKey: 'user_id' });
Favorite.belongsTo(User, { foreignKey: 'user_id' });
Listing.hasMany(Favorite, { foreignKey: 'listing_id', as: 'favorites' });
Favorite.belongsTo(Listing, { foreignKey: 'listing_id', as: 'listing' });

// Provider sharhlari
Provider.hasMany(ProviderReview, { foreignKey: 'provider_id', as: 'reviews' });
ProviderReview.belongsTo(Provider, { foreignKey: 'provider_id' });
User.hasMany(ProviderReview, { foreignKey: 'user_id' });
ProviderReview.belongsTo(User, { foreignKey: 'user_id' });

// Bildirishnomalar
User.hasMany(Notification, { foreignKey: 'user_id' });
Notification.belongsTo(User, { foreignKey: 'user_id' });

module.exports = {
  sequelize, User, Vehicle, Provider, Order,
  PartsStore, PartsInventory, Workshop, WorkshopService,
  Payment, Review, OtpCode, RefreshToken, ServiceRecord, Listing, Favorite,
  ProviderReview, Notification,
};
