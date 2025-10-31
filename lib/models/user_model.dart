class UserModel {
  final String id;
  final String fullName;
  final String address;
  final String phone;
  final bool gender;
  final DateTime dateOfBirth;
  final double salary;
  final DateTime createdAt;
  final String email;

  UserModel({
    required this.id,
    required this.fullName,
    required this.address,
    required this.phone,
    required this.gender,
    required this.dateOfBirth,
    required this.salary,
    required this.createdAt,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] ?? '',
        fullName: json['fullName'] ?? '',
        address: json['address'] ?? '',
        phone: json['phone'] ?? '',
        gender: json['gender'] ?? false,
        dateOfBirth: DateTime.tryParse(json['dateOfBirth'] ?? '') ?? DateTime(2000, 1, 1),
        salary: (json['salary'] ?? 0).toDouble(),
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        email: json['email'] ?? '',
      );

  Map<String, dynamic> toUpdateJson() => {
        'fullName': fullName,
        'address': address,
        'phone': phone,
        'gender': gender,
        'dateOfBirth': dateOfBirth.toIso8601String(),
        'salary': salary,
      };
}
