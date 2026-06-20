class OrderModel {
  final int id;
  final String serviceType;
  final String? description;
  final Map<String, double> pickupLocation;
  final Map<String, double>? destinationLocation;
  final Map<String, dynamic>? vehicleInfo;
  final String status;
  final double? price;
  final int? rating;
  final String? review;
  final DateTime createdAt;
  final DateTime? completedAt;
  final Map<String, dynamic>? provider;

  OrderModel({
    required this.id,
    required this.serviceType,
    this.description,
    required this.pickupLocation,
    this.destinationLocation,
    this.vehicleInfo,
    required this.status,
    this.price,
    this.rating,
    this.review,
    required this.createdAt,
    this.completedAt,
    this.provider,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      serviceType: json['service_type'],
      description: json['description'],
      pickupLocation: {
        'latitude': json['pickup_location']['latitude'].toDouble(),
        'longitude': json['pickup_location']['longitude'].toDouble(),
      },
      destinationLocation: json['destination_location'] != null
          ? {
              'latitude': json['destination_location']['latitude'].toDouble(),
              'longitude': json['destination_location']['longitude'].toDouble(),
            }
          : null,
      vehicleInfo: json['vehicle_info'],
      status: json['status'],
      price: json['price']?.toDouble(),
      rating: json['rating'],
      review: json['review'],
      createdAt: DateTime.parse(json['created_at']),
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      provider: json['provider'],
    );
  }
}
