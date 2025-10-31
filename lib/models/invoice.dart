class Invoice {
  final int invoiceId;
  final String customerName;
  final DateTime invoiceDate;
  final double totalAmount;
  final String paymentMethod;
  final String status;

  Invoice({
    required this.invoiceId,
    required this.customerName,
    required this.invoiceDate,
    required this.totalAmount,
    required this.paymentMethod,
    required this.status,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
        invoiceId: json['invoiceId'] ?? 0,
        customerName: json['customerName'] ?? '',
        invoiceDate: DateTime.tryParse(json['invoiceDate'] ?? '') ?? DateTime.now(),
        totalAmount: (json['totalAmount'] ?? 0).toDouble(),
        paymentMethod: json['paymentMethod'] ?? '',
        status: json['status'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'invoiceId': invoiceId,
        'customerName': customerName,
        'invoiceDate': invoiceDate.toIso8601String(),
        'totalAmount': totalAmount,
        'paymentMethod': paymentMethod,
        'status': status,
      };
}
