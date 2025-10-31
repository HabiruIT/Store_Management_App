class Payment {
  final int paymentId;
  final int invoiceId;
  final double amount;
  final String paymentMethod;
  final DateTime paymentDate;

  Payment({
    required this.paymentId,
    required this.invoiceId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentDate,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        paymentId: json['paymentId'] ?? 0,
        invoiceId: json['invoiceId'] ?? 0,
        amount: (json['amount'] ?? 0).toDouble(),
        paymentMethod: json['paymentMethod'] ?? '',
        paymentDate:
            DateTime.tryParse(json['paymentDate'] ?? '') ?? DateTime.now(),
      );
}
