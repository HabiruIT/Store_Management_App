import 'package:flutter_dotenv/flutter_dotenv.dart';

class Product {
  final int productId;
  final String productName;
  final String categoryName;
  final String unit;
  final double price;
  final double costPrice;
  final bool status;
  final String? imageUrl;

  Product({
    required this.productId,
    required this.productName,
    required this.categoryName,
    required this.unit,
    required this.price,
    required this.costPrice,
    required this.status,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final rawImage = json['imageUrl'] as String?;
    final baseHost = dotenv.env['BASE_HOST'] ?? '';
    String? fixedImage;

    if (rawImage != null && rawImage.isNotEmpty) {
      fixedImage = rawImage.replaceFirst('http://localhost:5085', baseHost);
    }

    return Product(
      productId: json['productId'] ?? 0,
      productName: json['productName'] ?? '',
      categoryName: json['categoryName'] ?? '',
      unit: json['unit'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      costPrice: (json['costPrice'] ?? 0).toDouble(),
      status: json['status'] ?? false,
      imageUrl: fixedImage,
    );
  }

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'productName': productName,
    'categoryName': categoryName,
    'unit': unit,
    'price': price,
    'costPrice': costPrice,
    'status': status,
    'imageUrl': imageUrl,
  };
}
