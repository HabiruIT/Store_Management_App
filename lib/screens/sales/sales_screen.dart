import 'package:flutter/material.dart';
import 'package:store_manament/models/invoice_detail.dart';
import 'package:store_manament/models/product.dart';
import '../../widgets/app_scaffold.dart';
import '../../service/api/invoice_service.dart';
import '../../service/api/invoice_detail_service.dart';
import '../../service/api/payment_service.dart';
import '../../service/api/product_service.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final _invoiceService = InvoiceService();
  final _invoiceDetailService = InvoiceDetailService();
  final _paymentService = PaymentService();
  final _productService = ProductService();

  int? _invoiceId;
  double _total = 0;
  String _paymentMethod = "Tiền mặt";
  bool _loading = false;

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<InvoiceDetail> _items = [];

  final _customerCtrl = TextEditingController(text: "Khách lẻ");
  final _createdByCtrl = TextEditingController(text: "Nhân viên A");
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final list = await _productService.fetchProducts();
    setState(() {
      _products = list;
      _filteredProducts = list;
    });
  }

  void _filterProducts(String query) {
    setState(() {
      _filteredProducts =
          _products
              .where(
                (p) =>
                    p.productName.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    });
  }

  Future<void> _createInvoice() async {
    setState(() => _loading = true);
    try {
      final invoice = await _invoiceService.createInvoice({
        "customerId": "1",
        "createdBy": _createdByCtrl.text,
        "paymentMethod": _paymentMethod,
      });
      setState(() {
        _invoiceId = invoice.invoiceId;
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('🧾 Đã tạo hóa đơn #${invoice.invoiceId}')),
      );
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tạo hóa đơn thất bại'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addProduct(Product p) async {
    if (_invoiceId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('⚠️ Hãy tạo hóa đơn trước')));
      return;
    }

    final ctrl = TextEditingController(text: '1');
    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Thêm ${p.productName}'),
            content: TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Số lượng'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final qty = int.tryParse(ctrl.text) ?? 1;
                  Navigator.pop(context);
                  final item = await _invoiceDetailService.addItem({
                    "invoiceId": _invoiceId,
                    "productId": p.productId,
                    "quantity": qty,
                    "unitPrice": p.price,
                    "discount": 0,
                  });
                  setState(() {
                    _items.add(item);
                    _total += item.lineTotal;
                  });
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                child: const Text('Thêm'),
              ),
            ],
          ),
    );
  }

  Future<void> _createPayment() async {
    if (_invoiceId == null || _items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Chưa có hóa đơn hoặc sản phẩm')),
      );
      return;
    }

    try {
      await _paymentService.createPayment({
        "invoiceId": _invoiceId,
        "amount": _total,
        "paymentMethod": _paymentMethod,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Thanh toán thành công'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _invoiceId = null;
        _items.clear();
        _total = 0;
      });
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thanh toán thất bại'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: '💳 Bán hàng',
      body: SafeArea(
        child: Column(
          children: [
            // ======================== PHẦN TRÊN: DANH SÁCH SẢN PHẨM ========================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: '🔍 Tìm sản phẩm...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: _filterProducts,
              ),
            ),

            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GridView.builder(
                  itemCount: _filteredProducts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 130,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, i) {
                    final p = _filteredProducts[i];
                    return InkWell(
                      onTap: () => _addProduct(p),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.shopping_bag_outlined,
                                size: 38,
                                color: Colors.teal,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                p.productName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${p.price.toStringAsFixed(0)} ₫',
                                style: const TextStyle(color: Colors.teal),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ======================== PHẦN DƯỚI: HÓA ĐƠN + THANH TOÁN ========================
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFF7F9FB),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, -1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_invoiceId == null) ...[
                    const Text(
                      '🧾 Tạo hóa đơn mới',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    /// 🔽 Dropdown chọn loại khách hàng
                    DropdownButtonFormField<String>(
                      value: _customerCtrl.text,
                      items: const [
                        DropdownMenuItem(
                          value: 'Khách lẻ',
                          child: Row(
                            children: [
                              Icon(Icons.person_outline, color: Colors.teal),
                              SizedBox(width: 6),
                              Text('Vãng lai'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Khách quen',
                          child: Row(
                            children: [
                              Icon(Icons.favorite_border, color: Colors.orange),
                              SizedBox(width: 6),
                              Text('Khách quen'),
                            ],
                          ),
                        ),
                      ],
                      onChanged:
                          (v) => setState(
                            () => _customerCtrl.text = v ?? 'Khách lẻ',
                          ),
                      decoration: const InputDecoration(
                        labelText: 'Loại khách hàng',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),

                    /// 💳 Phương thức thanh toán
                    DropdownButtonFormField<String>(
                      value: _paymentMethod,
                      items: const [
                        DropdownMenuItem(
                          value: 'Tiền mặt',
                          child: Text('Tiền mặt'),
                        ),
                        DropdownMenuItem(
                          value: 'Chuyển khoản',
                          child: Text('Chuyển khoản'),
                        ),
                        DropdownMenuItem(
                          value: 'Thẻ',
                          child: Text('Thẻ ngân hàng'),
                        ),
                      ],
                      onChanged:
                          (v) =>
                              setState(() => _paymentMethod = v ?? 'Tiền mặt'),
                      decoration: const InputDecoration(
                        labelText: 'Phương thức thanh toán',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),

                    /// 🧾 Nút tạo hóa đơn
                    ElevatedButton.icon(
                      onPressed: _loading ? null : _createInvoice,
                      icon: const Icon(Icons.receipt_long),
                      label: const Text('Tạo hóa đơn'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ] else ...[
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child:
                          _items.isEmpty
                              ? const Center(child: Text('Chưa có sản phẩm'))
                              : ListView.builder(
                                itemCount: _items.length,
                                itemBuilder: (context, i) {
                                  final item = _items[i];
                                  return ListTile(
                                    dense: true,
                                    title: Text(item.productName),
                                    subtitle: Text(
                                      'SL: ${item.quantity} | Giá: ${item.unitPrice.toStringAsFixed(0)}₫',
                                    ),
                                    trailing: Text(
                                      '${item.lineTotal.toStringAsFixed(0)}₫',
                                      style: const TextStyle(
                                        color: Colors.teal,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                              ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tổng cộng:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_total.toStringAsFixed(0)} ₫',
                          style: const TextStyle(
                            color: Colors.teal,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _createPayment,
                      icon: const Icon(Icons.payment),
                      label: const Text('Thanh toán'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
