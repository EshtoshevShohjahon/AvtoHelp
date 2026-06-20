class UserModel {
  final int id;
  final String phone;
  final String fullName;
  final String role;
  final String? avatarUrl;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.phone,
    required this.fullName,
    required this.role,
    this.avatarUrl,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      phone: json['phone'],
      fullName: json['full_name'],
      role: json['role'],
      avatarUrl: json['avatar_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'full_name': fullName,
      'role': role,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
