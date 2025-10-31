import 'dart:convert';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:store_manament/models/inventory.dart';

/// Service gọi API tồn kho
class InventoryService {
  InventoryService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  String get _baseUrl {
    final api = dotenv.env['API_URL'] ?? '';
    final prefix = api.endsWith('/') ? api : '$api/';
    return '${prefix}Inventories';
  }

  /// GET /Inventories/list
  Future<List<Inventory>> fetchAllInventories() async {
    try {
      final url = Uri.parse('$_baseUrl/list');
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List data = jsonResponse['data'] ?? [];
        return data.map((e) => Inventory.fromJson(e)).toList();
      } else {
        throw Exception('Không thể tải danh sách tồn kho');
      }
    } catch (e) {
      log('fetchAllInventories error: $e');
      rethrow;
    }
  }

  /// GET /Inventories/warehouse/{id}
  Future<List<Inventory>> fetchByWarehouse(int warehouseId) async {
    try {
      final url = Uri.parse('$_baseUrl/warehouse/$warehouseId');
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List data = jsonResponse['data'] ?? [];
        return data.map((e) => Inventory.fromJson(e)).toList();
      } else {
        throw Exception('Không thể tải tồn kho theo kho');
      }
    } catch (e) {
      log('fetchByWarehouse error: $e');
      rethrow;
    }
  }

  /// GET /Inventories/product/{id}
  Future<List<Inventory>> fetchByProduct(int productId) async {
    try {
      final url = Uri.parse('$_baseUrl/product/$productId');
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List data = jsonResponse['data'] ?? [];
        return data.map((e) => Inventory.fromJson(e)).toList();
      } else {
        throw Exception('Không thể tải tồn kho theo sản phẩm');
      }
    } catch (e) {
      log('fetchByProduct error: $e');
      rethrow;
    }
  }
}
