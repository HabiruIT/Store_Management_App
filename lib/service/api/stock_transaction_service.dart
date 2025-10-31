import 'dart:convert';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:store_manament/models/stock_transaction.dart';

/// Service gọi API giao dịch kho
class StockTransactionService {
  StockTransactionService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  String get _baseUrl {
    final api = dotenv.env['API_URL'] ?? '';
    final prefix = api.endsWith('/') ? api : '$api/';
    return '${prefix}StockTransactions';
  }

  /// GET /StockTransactions/list
  Future<List<StockTransaction>> fetchTransactions() async {
    try {
      final url = Uri.parse('$_baseUrl/list');
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List data = jsonResponse['data'] ?? [];
        return data.map((e) => StockTransaction.fromJson(e)).toList();
      } else {
        throw Exception('Không thể tải danh sách giao dịch kho');
      }
    } catch (e) {
      log('fetchTransactions error: $e');
      rethrow;
    }
  }

  /// GET /StockTransactions/detail/{id}
  Future<StockTransaction?> fetchTransactionDetail(int id) async {
    try {
      final url = Uri.parse('$_baseUrl/detail/$id');
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return StockTransaction.fromJson(jsonResponse['data']);
      } else {
        throw Exception('Không thể lấy chi tiết giao dịch kho');
      }
    } catch (e) {
      log('fetchTransactionDetail error: $e');
      rethrow;
    }
  }

  /// POST /StockTransactions/create
  Future<StockTransaction> createTransaction(Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('$_baseUrl/create');
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        return StockTransaction.fromJson(jsonResponse['data']);
      } else {
        throw Exception('Không thể tạo giao dịch kho');
      }
    } catch (e) {
      log('createTransaction error: $e');
      rethrow;
    }
  }
}
