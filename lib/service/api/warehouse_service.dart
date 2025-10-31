import 'dart:convert';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:store_manament/models/warehouse.dart';

class WarehouseService {
  WarehouseService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  String get _baseUrl {
    final api = dotenv.env['API_URL'] ?? '';
    final prefix = api.endsWith('/') ? api : '$api/';
    return '${prefix}Warehouses';
  }

  /// GET /Warehouses/list
  Future<List<Warehouse>> fetchWarehouses() async {
    try {
      final url = Uri.parse('$_baseUrl/list');
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'] ?? [];
        return data.map((e) => Warehouse.fromJson(e)).toList();
      } else {
        throw Exception('Không thể tải danh sách kho');
      }
    } catch (e) {
      log('fetchWarehouses error: $e');
      rethrow;
    }
  }

  /// GET /Warehouses/detail/{id}
  Future<Warehouse?> fetchWarehouseDetail(int id) async {
    try {
      final url = Uri.parse('$_baseUrl/detail/$id');
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return Warehouse.fromJson(jsonResponse['data']);
      } else {
        throw Exception('Không thể lấy chi tiết kho');
      }
    } catch (e) {
      log('fetchWarehouseDetail error: $e');
      rethrow;
    }
  }

  /// POST /Warehouses/create
  Future<Warehouse> createWarehouse(Map<String, dynamic> warehouse) async {
    try {
      final url = Uri.parse('$_baseUrl/create');
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(warehouse),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        return Warehouse.fromJson(jsonResponse);
      } else {
        throw Exception('Không thể tạo kho hàng');
      }
    } catch (e) {
      log('createWarehouse error: $e');
      rethrow;
    }
  }

  /// PUT /Warehouses/update/{id}
  Future<String> updateWarehouse(int id, Map<String, dynamic> warehouse) async {
    try {
      final url = Uri.parse('$_baseUrl/update/$id');
      final response = await _client.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(warehouse),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['message'] ?? 'Cập nhật kho hàng thành công';
      } else {
        throw Exception('Không thể cập nhật kho hàng');
      }
    } catch (e) {
      log('updateWarehouse error: $e');
      rethrow;
    }
  }

  /// DELETE /Warehouses/delete/{id}
  Future<String> deleteWarehouse(int id) async {
    try {
      final url = Uri.parse('$_baseUrl/delete/$id');
      final response = await _client.delete(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['message'] ?? 'Xóa kho hàng thành công';
      } else {
        throw Exception('Không thể xóa kho hàng');
      }
    } catch (e) {
      log('deleteWarehouse error: $e');
      rethrow;
    }
  }
}
