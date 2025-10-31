import 'package:flutter/material.dart';
import 'package:store_manament/models/invoice.dart';
import 'package:store_manament/models/invoice_detail.dart';
import 'package:store_manament/models/payment.dart';
import 'package:store_manament/models/product.dart';
import '../../widgets/app_scaffold.dart';
import '../../service/api/invoice_detail_service.dart';
import '../../service/api/payment_service.dart';
import '../../service/api/product_service.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final Invoice invoice;
  const InvoiceDetailScreen({super.key, required this.invoice});

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  final _detailService = InvoiceDetailService();
  final _paymentService = PaymentService();
  final _productService = ProductService();

  List<InvoiceDetail> _details = [];
  List<Payment> _payments = [];
  List<Product> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final details = await _detailService.fetchByInvoice(widget.invoice.invoiceId);
    final payments = await _paymentService.fetchPaymentsByInvoice(widget.invoice.invoiceId);
    final products = await _productService.fetchProducts();
    setState(() {
      _details = details;
      _payments = payments;
      _products = products;
      _loading = false;
    });
  }

  Future<void> _addItem() async {
    final result = await showDialog(
      context: context,
      builder: (_) => _AddItemDialog(products: _products),
    );

    if (result != null) {
      await _detailService.addItem({
        "invoiceId": widget.invoice.invoiceId,
        "productId": result['productId'],
        "quantity": result['quantity'],
        "unitPrice": result['unitPrice'],
        "discount": result['discount'],
      });
      _loadAll();
    }
  }

  Future<void> _addPayment() async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Thanh toán hóa đơn'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Số tiền thanh toán'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              await _paymentService.createPayment({
                "invoiceId": widget.invoice.invoiceId,
                "amount": double.tryParse(ctrl.text) ?? 0,
                "paymentMethod": widget.invoice.paymentMethod,
              });
              Navigator.pop(context);
              _loadAll();
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inv = widget.invoice;

    return AppScaffold(
      title: 'Hóa đơn #${inv.invoiceId}',
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAll,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Khách hàng: ${inv.customerName}'),
                    Text('Ngày tạo: ${inv.invoiceDate.toLocal().toString().substring(0, 16)}'),
                    Text('Trạng thái: ${inv.status}'),
                    Text('Thanh toán: ${inv.paymentMethod}'),
                    const Divider(height: 30),

                    /// Chi tiết sản phẩm
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Sản phẩm', style: Theme.of(context).textTheme.titleMedium),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: Colors.teal),
                          onPressed: _addItem,
                        ),
                      ],
                    ),
                    ..._details.map((d) => ListTile(
                          leading: const Icon(Icons.shopping_bag_outlined),
                          title: Text(d.productName),
                          subtitle: Text(
                              'SL: ${d.quantity}, Giá: ${d.unitPrice}₫, CK: ${d.discount}%'),
                          trailing: Text(
                            '${d.lineTotal}₫',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )),

                    const Divider(height: 30),

                    /// Thanh toán
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Thanh toán', style: Theme.of(context).textTheme.titleMedium),
                        IconButton(
                          icon: const Icon(Icons.payments_outlined, color: Colors.teal),
                          onPressed: _addPayment,
                        ),
                      ],
                    ),
                    ..._payments.map(
                      (p) => ListTile(
                        leading: const Icon(Icons.attach_money, color: Colors.green),
                        title: Text('${p.amount}₫'),
                        subtitle: Text(
                            'Ngày: ${p.paymentDate.toLocal().toString().substring(0, 16)} - ${p.paymentMethod}'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

/// Dialog thêm sản phẩm vào hóa đơn
class _AddItemDialog extends StatefulWidget {
  final List<Product> products;
  const _AddItemDialog({required this.products});

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  int? _productId;
  int _quantity = 1;
  double _discount = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm sản phẩm'),
      scrollable: true,
      content: Form(
        key: _formKey,
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              value: _productId,
              items: widget.products
                  .map((p) => DropdownMenuItem<int>(
                        value: p.productId,
                        child: Text(p.productName),
                      ))
                  .toList(),
              onChanged: (v) => _productId = v,
              decoration: const InputDecoration(
                labelText: 'Sản phẩm',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null ? 'Chọn sản phẩm' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Số lượng', border: OutlineInputBorder()),
              initialValue: '1',
              onChanged: (v) => _quantity = int.tryParse(v) ?? 1,
            ),
            const SizedBox(height: 10),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Chiết khấu (%)', border: OutlineInputBorder()),
              onChanged: (v) => _discount = double.tryParse(v) ?? 0,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final price = widget.products
                  .firstWhere((e) => e.productId == _productId)
                  .price;
              Navigator.pop(context, {
                "productId": _productId,
                "quantity": _quantity,
                "unitPrice": price,
                "discount": _discount,
              });
            }
          },
          child: const Text('Thêm'),
        ),
      ],
    );
  }
}
