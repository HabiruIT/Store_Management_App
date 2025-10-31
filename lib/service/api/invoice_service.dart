import 'dart:convert';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:store_manament/models/invoice.dart';

class InvoiceService {
  InvoiceService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  String get _baseUrl {
    final api = dotenv.env['API_URL'] ?? '';
    final prefix = api.endsWith('/') ? api : '$api/';
    return '${prefix}Invoices';
  }

  /// GET /Invoices/list
  Future<List<Invoice>> fetchInvoices() async {
    try {
      final url = Uri.parse('$_baseUrl/list');
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final List data = json.decode(response.body)['data'] ?? [];
        return data.map((e) => Invoice.fromJson(e)).toList();
      }
      throw Exception('Không thể tải danh sách hóa đơn');
    } catch (e) {
      log('fetchInvoices error: $e');
      rethrow;
    }
  }

  /// GET /Invoices/detail/{id}
  Future<Invoice?> fetchInvoiceDetail(int id) async {
    try {
      final url = Uri.parse('$_baseUrl/detail/$id');
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        return Invoice.fromJson(data);
      }
      throw Exception('Không thể lấy chi tiết hóa đơn');
    } catch (e) {
      log('fetchInvoiceDetail error: $e');
      rethrow;
    }
  }

  /// POST /Invoices/create
  Future<Invoice> createInvoice(Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('$_baseUrl/create');
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Invoice.fromJson(data);
      }
      throw Exception('Không thể tạo hóa đơn');
    } catch (e) {
      log('createInvoice error: $e');
      rethrow;
    }
  }

  /// PUT /Invoices/update-status/{id}?status={status}
  Future<String> updateInvoiceStatus(int id, String status) async {
    try {
      final url = Uri.parse('$_baseUrl/update-status/$id?status=$status');
      final response = await _client.put(url);

      if (response.statusCode == 200) {
        return json.decode(response.body)['message'] ?? 'Cập nhật thành công';
      }
      throw Exception('Không thể cập nhật trạng thái');
    } catch (e) {
      log('updateInvoiceStatus error: $e');
      rethrow;
    }
  }

  /// DELETE /Invoices/delete/{id}
  Future<String> deleteInvoice(int id) async {
    try {
      final url = Uri.parse('$_baseUrl/delete/$id');
      final response = await _client.delete(url);

      if (response.statusCode == 200) {
        return json.decode(response.body)['message'] ?? 'Xóa hóa đơn thành công';
      }
      throw Exception('Không thể xóa hóa đơn');
    } catch (e) {
      log('deleteInvoice error: $e');
      rethrow;
    }
  }
}
