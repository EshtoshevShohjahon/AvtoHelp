import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String phone;
  final String? fullName;
  final String role;
  final String preferredLanguage;

  const UserModel({required this.id, required this.phone, this.fullName, required this.role, required this.preferredLanguage});

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    id: j['id'], phone: j['phone'], fullName: j['full_name'],
    role: j['role'] ?? 'client', preferredLanguage: j['preferred_language'] ?? 'uz',
  );

  @override
  List<Object?> get props => [id];
}

class ProviderModel extends Equatable {
  final String id, userId, serviceType, status, kycStatus;
  final bool isVerified;
  final String? kycRejectReason;
  final double ratingAvg;
  final int ratingCount;

  const ProviderModel({required this.id, required this.userId, required this.serviceType,
    required this.status, required this.isVerified, required this.kycStatus,
    this.kycRejectReason, required this.ratingAvg, required this.ratingCount});

  factory ProviderModel.fromJson(Map<String, dynamic> j) => ProviderModel(
    id: j['id'], userId: j['user_id'], serviceType: j['service_type'],
    status: j['status'] ?? 'offline', isVerified: j['is_verified'] ?? false,
    kycStatus: j['kyc_status'] ?? 'pending', kycRejectReason: j['kyc_reject_reason'],
    ratingAvg: (j['rating_avg'] ?? 0).toDouble(), ratingCount: j['rating_count'] ?? 0,
  );

  @override
  List<Object?> get props => [id];
}

class OrderModel extends Equatable {
  final String id, clientId, serviceType, status;
  final String? providerId, problemType, pickupAddress, destinationAddress, cancelReason;
  final double pickupLat, pickupLng;
  final double? destinationLat, destinationLng, price;
  final DateTime createdAt;

  const OrderModel({required this.id, required this.clientId, this.providerId,
    required this.serviceType, required this.status, this.problemType,
    required this.pickupLat, required this.pickupLng, this.pickupAddress,
    this.destinationLat, this.destinationLng, this.destinationAddress,
    this.price, this.cancelReason, required this.createdAt});

  factory OrderModel.fromJson(Map<String, dynamic> j) => OrderModel(
    id: j['id'], clientId: j['client_id'], providerId: j['provider_id'],
    serviceType: j['service_type'], status: j['status'], problemType: j['problem_type'],
    pickupLat: (j['pickup_lat'] ?? 0).toDouble(), pickupLng: (j['pickup_lng'] ?? 0).toDouble(),
    pickupAddress: j['pickup_address'], destinationLat: j['destination_lat']?.toDouble(),
    destinationLng: j['destination_lng']?.toDouble(), destinationAddress: j['destination_address'],
    price: j['price']?.toDouble(), cancelReason: j['cancel_reason'],
    createdAt: DateTime.tryParse(j['created_at'] ?? '') ?? DateTime.now(),
  );

  bool get isActive => ['accepted', 'en_route', 'in_progress'].contains(status);
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  @override
  List<Object?> get props => [id, status];
}

class PartsStoreModel extends Equatable {
  final String id, name;
  final String? address;
  final double lat, lng, distanceKm;
  final Map<String, dynamic>? workingHours;

  const PartsStoreModel({required this.id, required this.name, this.address,
    required this.lat, required this.lng, required this.distanceKm, this.workingHours});

  factory PartsStoreModel.fromJson(Map<String, dynamic> j) => PartsStoreModel(
    id: j['id'], name: j['name'], address: j['address'],
    lat: (j['lat'] ?? 0).toDouble(), lng: (j['lng'] ?? 0).toDouble(),
    distanceKm: (j['distance_km'] ?? 0).toDouble(), workingHours: j['working_hours'],
  );

  @override
  List<Object?> get props => [id];
}

class WorkshopModel extends Equatable {
  final String id, name;
  final String? address;
  final double lat, lng, distanceKm, ratingAvg;
  final int ratingCount;
  final List<String> specializations;

  const WorkshopModel({required this.id, required this.name, this.address,
    required this.lat, required this.lng, required this.distanceKm,
    required this.ratingAvg, required this.ratingCount, required this.specializations});

  factory WorkshopModel.fromJson(Map<String, dynamic> j) => WorkshopModel(
    id: j['id'], name: j['name'], address: j['address'],
    lat: (j['lat'] ?? 0).toDouble(), lng: (j['lng'] ?? 0).toDouble(),
    distanceKm: (j['distance_km'] ?? 0).toDouble(), ratingAvg: (j['rating_avg'] ?? 0).toDouble(),
    ratingCount: j['rating_count'] ?? 0,
    specializations: (j['specializations'] as List?)?.map((e) => e.toString()).toList() ?? [],
  );

  @override
  List<Object?> get props => [id];
}
