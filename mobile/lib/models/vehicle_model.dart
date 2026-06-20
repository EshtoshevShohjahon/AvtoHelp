class VehicleModel {
  final int id;
  final String brand;
  final String model;
  final int year;
  final String plateNumber;
  final int currentMileage;
  final int oilChangeInterval;
  final DateTime createdAt;
  final int? oilChangeCount;
  final DateTime? lastOilChange;

  VehicleModel({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.plateNumber,
    required this.currentMileage,
    required this.oilChangeInterval,
    required this.createdAt,
    this.oilChangeCount,
    this.lastOilChange,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'],
      brand: json['brand'],
      model: json['model'],
      year: json['year'],
      plateNumber: json['plate_number'],
      currentMileage: json['current_mileage'],
      oilChangeInterval: json['oil_change_interval'] ?? 10000,
      createdAt: DateTime.parse(json['created_at']),
      oilChangeCount: json['oil_change_count'],
      lastOilChange: json['last_oil_change'] != null 
          ? DateTime.parse(json['last_oil_change']) 
          : null,
    );
  }

  String get displayName => '$brand $model ($year)';
}
