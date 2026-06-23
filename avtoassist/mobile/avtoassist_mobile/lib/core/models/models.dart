import 'package:equatable/equatable.dart';

// ─── User ──────────────────────────────────────────
class UserModel extends Equatable {
  final String id;
  final String phone;
  final String? fullName;
  final String role; // 'client' | 'provider' | 'admin'
  final String preferredLanguage;
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.phone,
    this.fullName,
    required this.role,
    required this.preferredLanguage,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        id: j['id'],
        phone: j['phone'],
        fullName: j['full_name'],
        role: j['role'] ?? 'client',
        preferredLanguage: j['preferred_language'] ?? 'uz',
        avatarUrl: j['avatar_url'],
      );

  @override
  List<Object?> get props => [id, role, fullName, avatarUrl];
}

// ─── Vehicle ──────────────────────────────────────
class VehicleModel extends Equatable {
  final String? id;
  final String techPassport;
  final String brand;
  final String model;
  final String plateNumber;
  final int? year;
  final String? color;

  const VehicleModel({
    this.id,
    required this.techPassport,
    required this.brand,
    required this.model,
    required this.plateNumber,
    this.year,
    this.color,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> j) => VehicleModel(
        id: j['id'],
        techPassport: j['tech_passport'] ?? '',
        brand: j['brand'] ?? '',
        model: j['model'] ?? '',
        plateNumber: j['plate_number'] ?? '',
        year: j['year'],
        color: j['color'],
      );

  String get title => '$brand $model';

  @override
  List<Object?> get props => [id, techPassport];
}

// ─── Provider ─────────────────────────────────────
class ProviderModel extends Equatable {
  final String id;
  final String userId;
  final String serviceType;
  final String status;
  final bool isVerified;
  final String kycStatus;
  final String? kycRejectReason;
  final double ratingAvg;
  final int ratingCount;

  const ProviderModel({
    required this.id,
    required this.userId,
    required this.serviceType,
    required this.status,
    required this.isVerified,
    required this.kycStatus,
    this.kycRejectReason,
    required this.ratingAvg,
    required this.ratingCount,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> j) => ProviderModel(
        id: j['id'],
        userId: j['user_id'],
        serviceType: j['service_type'],
        status: j['status'] ?? 'offline',
        isVerified: j['is_verified'] ?? false,
        kycStatus: j['kyc_status'] ?? 'pending',
        kycRejectReason: j['kyc_reject_reason'],
        ratingAvg: (j['rating_avg'] ?? 0).toDouble(),
        ratingCount: j['rating_count'] ?? 0,
      );

  @override
  List<Object?> get props => [id];
}

// ─── Order ────────────────────────────────────────
class OrderModel extends Equatable {
  final String id;
  final String clientId;
  final String? providerId;
  final String serviceType;
  final String status;
  final String? problemType;
  final double pickupLat;
  final double pickupLng;
  final String? pickupAddress;
  final double? destinationLat;
  final double? destinationLng;
  final String? destinationAddress;
  final double? price;
  final String? cancelReason;
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    required this.clientId,
    this.providerId,
    required this.serviceType,
    required this.status,
    this.problemType,
    required this.pickupLat,
    required this.pickupLng,
    this.pickupAddress,
    this.destinationLat,
    this.destinationLng,
    this.destinationAddress,
    this.price,
    this.cancelReason,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> j) => OrderModel(
        id: j['id'],
        clientId: j['client_id'],
        providerId: j['provider_id'],
        serviceType: j['service_type'],
        status: j['status'],
        problemType: j['problem_type'],
        pickupLat: (j['pickup_lat'] ?? 0).toDouble(),
        pickupLng: (j['pickup_lng'] ?? 0).toDouble(),
        pickupAddress: j['pickup_address'],
        destinationLat: j['destination_lat']?.toDouble(),
        destinationLng: j['destination_lng']?.toDouble(),
        destinationAddress: j['destination_address'],
        price: j['price']?.toDouble(),
        cancelReason: j['cancel_reason'],
        createdAt: DateTime.tryParse(j['created_at'] ?? '') ?? DateTime.now(),
      );

  bool get isActive => ['accepted', 'en_route', 'in_progress'].contains(status);
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  @override
  List<Object?> get props => [id, status];
}

// ─── PartsStore ──────────────────────────────────────
class PartsStoreModel extends Equatable {
  final String id;
  final String name;
  final String? address;
  final double lat;
  final double lng;
  final double distanceKm;
  final Map<String, dynamic>? workingHours;

  const PartsStoreModel({
    required this.id,
    required this.name,
    this.address,
    required this.lat,
    required this.lng,
    required this.distanceKm,
    this.workingHours,
  });

  factory PartsStoreModel.fromJson(Map<String, dynamic> j) => PartsStoreModel(
        id: j['id'],
        name: j['name'],
        address: j['address'],
        lat: (j['lat'] ?? 0).toDouble(),
        lng: (j['lng'] ?? 0).toDouble(),
        distanceKm: (j['distance_km'] ?? 0).toDouble(),
        workingHours: j['working_hours'],
      );

  @override
  List<Object?> get props => [id];
}

// ─── Workshop ─────────────────────────────────────
class WorkshopModel extends Equatable {
  final String id;
  final String name;
  final String? address;
  final double lat;
  final double lng;
  final double distanceKm;
  final double ratingAvg;
  final int ratingCount;
  final List<String> specializations;

  const WorkshopModel({
    required this.id,
    required this.name,
    this.address,
    required this.lat,
    required this.lng,
    required this.distanceKm,
    required this.ratingAvg,
    required this.ratingCount,
    required this.specializations,
  });

  factory WorkshopModel.fromJson(Map<String, dynamic> j) => WorkshopModel(
        id: j['id'],
        name: j['name'],
        address: j['address'],
        lat: (j['lat'] ?? 0).toDouble(),
        lng: (j['lng'] ?? 0).toDouble(),
        distanceKm: (j['distance_km'] ?? 0).toDouble(),
        ratingAvg: (j['rating_avg'] ?? 0).toDouble(),
        ratingCount: j['rating_count'] ?? 0,
        specializations: (j['specializations'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );

  @override
  List<Object?> get props => [id];
}
