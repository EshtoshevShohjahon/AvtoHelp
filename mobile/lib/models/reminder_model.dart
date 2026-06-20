class ReminderModel {
  final int id;
  final int vehicleId;
  final String reminderType;
  final int nextServiceMileage;
  final DateTime? lastServiceDate;
  final bool isNotified;
  final String? brand;
  final String? model;
  final String? plateNumber;
  final int? currentMileage;

  ReminderModel({
    required this.id,
    required this.vehicleId,
    required this.reminderType,
    required this.nextServiceMileage,
    this.lastServiceDate,
    required this.isNotified,
    this.brand,
    this.model,
    this.plateNumber,
    this.currentMileage,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'],
      vehicleId: json['vehicle_id'],
      reminderType: json['reminder_type'],
      nextServiceMileage: json['next_service_mileage'],
      lastServiceDate: json['last_service_date'] != null
          ? DateTime.parse(json['last_service_date'])
          : null,
      isNotified: json['is_notified'] ?? false,
      brand: json['brand'],
      model: json['model'],
      plateNumber: json['plate_number'],
      currentMileage: json['current_mileage'],
    );
  }

  int get mileageRemaining {
    if (currentMileage == null) return 0;
    return nextServiceMileage - currentMileage!;
  }

  bool get shouldNotify => mileageRemaining <= 500;

  String get displayText {
    final km = mileageRemaining;
    if (km <= 0) {
      return 'Moy almashtirish vaqti keldi!';
    } else if (km <= 500) {
      return '$km km qoldi - tez orada moy almashtiring';
    } else {
      return '$km km qoldi';
    }
  }
}
