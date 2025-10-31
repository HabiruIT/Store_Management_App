import 'dart:convert';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:store_manament/models/app_session.dart';
import 'package:store_manament/models/auth_response.dart';

class AuthenticateService {
  AuthenticateService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  String get _baseUrl {
    final api = dotenv.env['API_URL'] ?? '';
    final prefix = api.endsWith('/') ? api : '$api/';
    return '${prefix}Auth';
  }

  /// 🔐 Đăng nhập và lưu vào AppSession
  Future<AuthResponse> login(String email, String password) async {
    try {
      final url = Uri.parse('$_baseUrl/login');
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        final auth = AuthResponse.fromJson(jsonResponse);

        // 🧩 Giải mã JWT token để lấy role
        final token = auth.token!;
        String role = 'User';
        try {
          final parts = token.split('.');
          if (parts.length == 3) {
            final payload = utf8.decode(
              base64Url.decode(base64Url.normalize(parts[1])),
            );
            final data = jsonDecode(payload);
            role = data['role']?.toString() ?? 'User';
          }
        } catch (e) {
          role = 'User';
        }

        // ✅ Lưu token + user + role vào AppSession
        await AppSession.saveSession(
          token: auth.token!,
          refreshToken: auth.refreshToken!,
          expiresAt: auth.expiresAt!,
          fullName: auth.fullName ?? '',
          email: auth.email ?? '',
          role: role, // 👈 thêm dòng này
        );
        await AppSession.loadSession();
        return auth;
      } else {
        throw Exception(jsonResponse['message'] ?? 'Sai email hoặc mật khẩu');
      }
    } catch (e, s) {
      log('login error: $e\n$s');
      rethrow;
    }
  }

  /// 📝 Đăng ký
  Future<String> register(Map<String, dynamic> body) async {
    try {
      final regex = RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$',
      );
      if (!regex.hasMatch(body['password'] ?? '')) {
        throw Exception(
          'Mật khẩu phải có chữ hoa, chữ thường, số, ký tự đặc biệt và ≥ 8 ký tự',
        );
      }

      // ✅ Thêm trường "role" mặc định nếu chưa có
      if (!body.containsKey('role') || body['role'] == null) {
        body['role'] = 'user';
      }

      final url = Uri.parse('$_baseUrl/register');
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      final jsonResponse = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonResponse['message'] ?? 'Đăng ký thành công';
      } else {
        throw Exception(jsonResponse['message'] ?? 'Đăng ký thất bại');
      }
    } catch (e, s) {
      log('register error: $e\n$s');
      rethrow;
    }
  }
}
