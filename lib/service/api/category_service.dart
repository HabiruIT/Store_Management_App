import 'dart:convert';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:store_manament/models/category.dart';

class CategoryService {
  CategoryService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  String get _baseUrl {
    final api = dotenv.env['API_URL'] ?? '';
    // Ensure trailing slash handling
    final prefix = api.endsWith('/') ? api : '$api/';

    return '${prefix}Categories';
  }

  /// GET /Categories/list
  Future<List<Category>> fetchCategories() async {
    try {
      final url = Uri.parse('$_baseUrl/list');
      final resp = await _client.get(url);
      if (resp.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(resp.body);
        final data = body['data'] as List<dynamic>? ?? [];
        return data
            .map((e) => Category.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      log('$_baseUrl/list');
      log('Failed to fetch categories: status=${resp.statusCode}');
      return <Category>[];
    } catch (e, _) {
      log('Exception in fetchCategories: $e');
      return <Category>[];
    }
  }

  /// POST /Categories/create
  /// request body: { "categoryName": "string" }
  Future<Category> createCategory(String categoryName) async {
    try {
      final url = Uri.parse('$_baseUrl/create');
      final resp = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'categoryName': categoryName}),
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final Map<String, dynamic> body = json.decode(resp.body);
        // The API returns the created object
        return Category.fromJson(body);
      }
      log(
        'Failed to create category: status=${resp.statusCode} body=${resp.body}',
      );
      // Return a placeholder Category indicating failure
      return Category(categoryId: -1, categoryName: categoryName);
    } catch (e, _) {
      log('Exception in createCategory: $e');
      return Category(categoryId: -1, categoryName: categoryName);
    }
  }

  /// PUT /Categories/update/{id}
  Future<void> updateCategory(int id, String categoryName) async {
    try {
      final url = Uri.parse('$_baseUrl/update/$id');
      final resp = await _client.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'categoryName': categoryName}),
      );

      if (resp.statusCode == 200) {
        return;
      }
      log(
        'Failed to update category: status=${resp.statusCode} body=${resp.body}',
      );
      return;
    } catch (e, _) {
      log('Exception in updateCategory: $e');
      return;
    }
  }

  /// DELETE /Categories/delete/{id}
  Future<void> deleteCategory(int id) async {
    try {
      final url = Uri.parse('$_baseUrl/delete/$id');
      final resp = await _client.delete(url);
      if (resp.statusCode == 200) {
        return;
      }
      log(
        'Failed to delete category: status=${resp.statusCode} body=${resp.body}',
      );
      return;
    } catch (e, _) {
      log('Exception in deleteCategory: $e');
      return;
    }
  }

  void dispose() {
    _client.close();
  }
}
