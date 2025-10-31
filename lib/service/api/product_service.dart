import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:store_manament/models/product.dart';
class ProductService {
  ProductService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  String get _baseUrl {
    final api = dotenv.env['API_URL'] ?? '';
    final prefix = api.endsWith('/') ? api : '$api/';
    return '${prefix}Products';
  }

  /// GET /Products/list
  Future<List<Product>> fetchProducts() async {
    try {
      final url = Uri.parse('$_baseUrl/list');
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'];
        return data.map((e) => Product.fromJson(e)).toList();
      } else {
        throw Exception('Không thể tải danh sách sản phẩm');
      }
    } catch (e) {
      log('fetchProducts error: $e');
      rethrow;
    }
  }

  /// GET /Products/detail/{id}
  Future<Product?> fetchProductDetail(int id) async {
    try {
      final url = Uri.parse('$_baseUrl/detail/$id');
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return Product.fromJson(jsonResponse['data']);
      } else {
        throw Exception('Không thể lấy chi tiết sản phẩm');
      }
    } catch (e) {
      log('fetchProductDetail error: $e');
      rethrow;
    }
  }

  /// GET /Products/by-category/{categoryId}
  Future<List<Product>> fetchProductsByCategory(int categoryId) async {
    try {
      final url = Uri.parse('$_baseUrl/by-category/$categoryId');
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'];
        return data.map((e) => Product.fromJson(e)).toList();
      } else {
        throw Exception('Không thể lấy sản phẩm theo danh mục');
      }
    } catch (e) {
      log('fetchProductsByCategory error: $e');
      rethrow;
    }
  }

  /// POST /Products/create
  Future<Product> createProduct(Map<String, dynamic> product) async {
    try {
      final url = Uri.parse('$_baseUrl/create');
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        return Product.fromJson(jsonResponse);
      } else {
        throw Exception('Không thể tạo sản phẩm');
      }
    } catch (e) {
      log('createProduct error: $e');
      rethrow;
    }
  }

  /// POST /Products/upload-image/{id}
  Future<bool> uploadImage(int id, File imageFile) async {
    try {
      final url = Uri.parse('$_baseUrl/upload-image/$id');
      final request = http.MultipartRequest('POST', url);
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return response.statusCode == 200;
    } catch (e) {
      log('uploadImage error: $e');
      rethrow;
    }
  }

  /// PUT /Products/update/{id}
  Future<String> updateProduct(int id, Map<String, dynamic> product) async {
    try {
      final url = Uri.parse('$_baseUrl/update/$id');
      final response = await _client.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['message'] ?? 'Cập nhật thành công';
      } else {
        throw Exception('Không thể cập nhật sản phẩm');
      }
    } catch (e) {
      log('updateProduct error: $e');
      rethrow;
    }
  }

  /// DELETE /Products/delete/{id}
  Future<String> deleteProduct(int id) async {
    try {
      final url = Uri.parse('$_baseUrl/delete/$id');
      final response = await _client.delete(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['message'] ?? 'Xóa sản phẩm thành công';
      } else {
        throw Exception('Không thể xóa sản phẩm');
      }
    } catch (e) {
      log('deleteProduct error: $e');
      rethrow;
    }
  }
}
