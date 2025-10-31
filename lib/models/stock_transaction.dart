/// Model giao dịch kho
class StockTransaction {
  final int transactionId;
  final int warehouseId;
  final int productId;
  final String productName;
  final String transactionType;
  final int quantity;
  final String createdBy;
  final DateTime createdAt;

  StockTransaction({
    required this.transactionId,
    required this.warehouseId,
    required this.productId,
    required this.productName,
    required this.transactionType,
    required this.quantity,
    required this.createdBy,
    required this.createdAt,
  });

  factory StockTransaction.fromJson(Map<String, dynamic> json) =>
      StockTransaction(
        transactionId: json['transactionId'] ?? 0,
        warehouseId: json['warehouseId'] ?? 0,
        productId: json['productId'] ?? 0,
        productName: json['productName'] ?? '',
        transactionType: json['transactionType'] ?? '',
        quantity: json['quantity'] ?? 0,
        createdBy: json['createdBy'] ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
    'transactionId': transactionId,
    'warehouseId': warehouseId,
    'productId': productId,
    'productName': productName,
    'transactionType': transactionType,
    'quantity': quantity,
    'createdBy': createdBy,
    'createdAt': createdAt.toIso8601String(),
  };
}
