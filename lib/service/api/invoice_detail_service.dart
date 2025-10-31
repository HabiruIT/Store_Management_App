import 'dart:convert';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:store_manament/models/invoice_detail.dart';

class InvoiceDetailService {
  InvoiceDetailService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  String get _baseUrl {
    final api = dotenv.env['API_URL'] ?? '';
    final prefix = api.endsWith('/') ? api : '$api/';
    return '${prefix}InvoiceDetails';
  }

  /// POST /InvoiceDetails/add-item
  Future<InvoiceDetail> addItem(Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('$_baseUrl/add-item');
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body)['data'];
        return InvoiceDetail.fromJson(data);
      }
      throw Exception('Không thể thêm sản phẩm vào hóa đơn');
    } catch (e) {
      log('addItem error: $e');
      rethrow;
    }
  }

  /// GET /InvoiceDetails/invoice/{id}
  Future<List<InvoiceDetail>> fetchByInvoice(int invoiceId) async {
    try {
      final url = Uri.parse('$_baseUrl/invoice/$invoiceId');
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final List data = json.decode(response.body)['data'] ?? [];
        return data.map((e) => InvoiceDetail.fromJson(e)).toList();
      }
      throw Exception('Không thể tải chi tiết hóa đơn');
    } catch (e) {
      log('fetchByInvoice error: $e');
      rethrow;
    }
  }

  /// DELETE /InvoiceDetails/delete-item/{invoiceId}/{productId}
  Future<String> deleteItem(int invoiceId, int productId) async {
    try {
      final url = Uri.parse('$_baseUrl/delete-item/$invoiceId/$productId');
      final response = await _client.delete(url);

      if (response.statusCode == 200) {
        return json.decode(response.body)['message'] ?? 'Đã xóa sản phẩm khỏi hóa đơn';
      }
      throw Exception('Không thể xóa sản phẩm');
    } catch (e) {
      log('deleteItem error: $e');
      rethrow;
    }
  }
}
