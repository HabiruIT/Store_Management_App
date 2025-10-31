/// Model tồn kho
class Inventory {
  final int warehouseId;
  final String warehouseName;
  final int productId;
  final String productName;
  final int quantity;

  Inventory({
    required this.warehouseId,
    required this.warehouseName,
    required this.productId,
    required this.productName,
    required this.quantity,
  });

  factory Inventory.fromJson(Map<String, dynamic> json) => Inventory(
    warehouseId: json['warehouseId'] ?? 0,
    warehouseName: json['warehouseName'] ?? '',
    productId: json['productId'] ?? 0,
    productName: json['productName'] ?? '',
    quantity: json['quantity'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'warehouseId': warehouseId,
    'warehouseName': warehouseName,
    'productId': productId,
    'productName': productName,
    'quantity': quantity,
  };
}
