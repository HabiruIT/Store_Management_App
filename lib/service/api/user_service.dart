import 'dart:convert';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:store_manament/models/app_session.dart';
import 'package:store_manament/models/user_model.dart';

class UserService {
  UserService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  String get _baseUrl {
    final api = dotenv.env['API_URL'] ?? '';
    final prefix = api.endsWith('/') ? api : '$api/';
    return '${prefix}Users';
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (AppSession.token != null) 'Authorization': 'Bearer ${AppSession.token}',
  };

  /// GET /Users/list
  Future<List<UserModel>> fetchUsers() async {
    try {
      final url = Uri.parse('$_baseUrl/list');
      final response = await _client.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final List data = json.decode(response.body)['data'] ?? [];
        return data.map((e) => UserModel.fromJson(e)).toList();
      }
      throw Exception('Không thể tải danh sách người dùng');
    } catch (e) {
      log('fetchUsers error: $e');
      rethrow;
    }
  }

  /// GET /Users/{id}
  Future<UserModel?> fetchUserDetail(String id) async {
    try {
      final url = Uri.parse('$_baseUrl/$id');
      final response = await _client.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        return UserModel.fromJson(data);
      }
      throw Exception('Không thể tải thông tin người dùng');
    } catch (e) {
      log('fetchUserDetail error: $e');
      rethrow;
    }
  }

  /// PUT /Users/update/{id}
  Future<String> updateUser(String id, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('$_baseUrl/update/$id');

      // 🔧 Fix: Format lại dateOfBirth chỉ còn phần ngày (yyyy-MM-dd)
      if (body.containsKey('dateOfBirth') && body['dateOfBirth'] != null) {
        final date = DateTime.tryParse(body['dateOfBirth']);
        if (date != null) {
          body['dateOfBirth'] =
              date.toIso8601String().split('T').first; // ✅ yyyy-MM-dd
        }
      }

      // 🔧 Fix: Ép các trường kiểu double về int nếu cần
      if (body.containsKey('salary')) {
        final value = body['salary'];
        if (value is double) {
          body['salary'] = value.toInt(); // ✅ bỏ phần thập phân
        } else if (value is String) {
          // Nếu salary nhập từ TextField là chuỗi
          body['salary'] = int.tryParse(value.split('.')[0]) ?? 0;
        }
      }

      log('Updating user at $url with body: $body');

      final response = await _client.put(
        url,
        headers: _headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body)['message'] ?? 'Cập nhật thành công';
      } else {
        log('Response body: ${response.body}');
        throw Exception('Không thể cập nhật người dùng');
      }
    } catch (e) {
      log('updateUser error: $e');
      rethrow;
    }
  }

  /// DELETE /Users/delete/{id}
  Future<String> deleteUser(String id) async {
    try {
      final url = Uri.parse('$_baseUrl/delete/$id');
      final response = await _client.delete(url, headers: _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body)['message'] ??
            'Xóa người dùng thành công';
      }
      throw Exception('Không thể xóa người dùng');
    } catch (e) {
      log('deleteUser error: $e');
      rethrow;
    }
  }
}
