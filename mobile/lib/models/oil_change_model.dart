class OilChangeModel {
  final int id;
  final int vehicleId;
  final String oilType;
  final int mileage;
  final double? price;
  final String? location;
  final String? notes;
  final DateTime changeDate;

  OilChangeModel({
    required this.id,
    required this.vehicleId,
    required this.oilType,
    required this.mileage,
    this.price,
    this.location,
    this.notes,
    required this.changeDate,
  });

  factory OilChangeModel.fromJson(Map<String, dynamic> json) {
    return OilChangeModel(
      id: json['id'],
      vehicleId: json['vehicle_id'],
      oilType: json['oil_type'],
      mileage: json['mileage'],
      price: json['price']?.toDouble(),
      location: json['location'],
      notes: json['notes'],
      changeDate: DateTime.parse(json['change_date']),
    );
  }
}
