import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AppSession {
  static String? token;
  static String? refreshToken;
  static DateTime? expiresAt;
  static String? fullName;
  static String? email;
  static String? role; // 👈 thêm role

  static const _key = 'app_session';

  static bool get isLoggedIn =>
      token != null && expiresAt != null && DateTime.now().isBefore(expiresAt!);

  static Future<void> saveSession({
    required String token,
    required String refreshToken,
    required DateTime expiresAt,
    required String fullName,
    required String email,
    required String role, // 👈 thêm
  }) async {
    AppSession.token = token;
    AppSession.refreshToken = refreshToken;
    AppSession.expiresAt = expiresAt;
    AppSession.fullName = fullName;
    AppSession.email = email;
    AppSession.role = role;

    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode({
      'token': token,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt.toIso8601String(),
      'fullName': fullName,
      'email': email,
      'role': role, 
    });
    await prefs.setString(_key, data);
  }

  static Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return;

    try {
      final data = jsonDecode(jsonString);
      token = data['token'];
      refreshToken = data['refreshToken'];
      expiresAt = DateTime.tryParse(data['expiresAt']);
      fullName = data['fullName'];
      email = data['email'];
      role = data['role']; // 👈 đọc lại
    } catch (_) {
      await clearSession();
    }
  }

  static Future<void> clearSession() async {
    token = null;
    refreshToken = null;
    expiresAt = null;
    fullName = null;
    email = null;
    role = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
