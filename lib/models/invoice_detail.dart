class InvoiceDetail {
  final int invoiceId;
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double discount;
  final double lineTotal;

  InvoiceDetail({
    required this.invoiceId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.discount,
    required this.lineTotal,
  });

  factory InvoiceDetail.fromJson(Map<String, dynamic> json) => InvoiceDetail(
        invoiceId: json['invoiceId'] ?? 0,
        productId: json['productId'] ?? 0,
        productName: json['productName'] ?? '',
        quantity: json['quantity'] ?? 0,
        unitPrice: (json['unitPrice'] ?? 0).toDouble(),
        discount: (json['discount'] ?? 0).toDouble(),
        lineTotal: (json['lineTotal'] ?? 0).toDouble(),
      );
}
