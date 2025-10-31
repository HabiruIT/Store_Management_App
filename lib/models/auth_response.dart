class AuthResponse {
  final String message;
  final String? token;
  final String? refreshToken;
  final DateTime? expiresAt;
  final String? fullName;
  final String? email;

  AuthResponse({
    required this.message,
    this.token,
    this.refreshToken,
    this.expiresAt,
    this.fullName,
    this.email,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        message: json['message'] ?? '',
        token: json['token'],
        refreshToken: json['refreshToken'],
        expiresAt: json['expiresAt'] != null
            ? DateTime.tryParse(json['expiresAt'])
            : null,
        fullName: json['user']?['fullName'],
        email: json['user']?['email'],
      );
}