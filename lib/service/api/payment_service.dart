import 'dart:convert';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:store_manament/models/payment.dart';

class PaymentService {
  PaymentService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  String get _baseUrl {
    final api = dotenv.env['API_URL'] ?? '';
    final prefix = api.endsWith('/') ? api : '$api/';
    return '${prefix}Payments';
  }

  /// POST /Payments/create
  Future<Payment> createPayment(Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('$_baseUrl/create');
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body)['data'];
        return Payment.fromJson(data);
      }
      throw Exception('Không thể ghi nhận thanh toán');
    } catch (e) {
      log('createPayment error: $e');
      rethrow;
    }
  }

  /// GET /Payments/invoice/{id}
  Future<List<Payment>> fetchPaymentsByInvoice(int invoiceId) async {
    try {
      final url = Uri.parse('$_baseUrl/invoice/$invoiceId');
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final List data = json.decode(response.body)['data'] ?? [];
        return data.map((e) => Payment.fromJson(e)).toList();
      }
      throw Exception('Không thể tải danh sách thanh toán');
    } catch (e) {
      log('fetchPaymentsByInvoice error: $e');
      rethrow;
    }
  }
}
