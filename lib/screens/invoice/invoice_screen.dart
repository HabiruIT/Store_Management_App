import 'package:flutter/material.dart';
import 'package:store_manament/models/invoice.dart';
import '../../widgets/app_scaffold.dart';
import '../../service/api/invoice_service.dart';
import 'invoice_detail_screen.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final InvoiceService _service = InvoiceService();
  List<Invoice> _invoices = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    setState(() => _loading = true);
    final data = await _service.fetchInvoices();
    setState(() {
      _invoices = data;
      _loading = false;
    });
  }

  Future<void> _deleteInvoice(int id) async {
    try {
      await _service.deleteInvoice(id);
      _loadInvoices();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã xóa hóa đơn')));
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xóa thất bại'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToDetail(Invoice inv) {
    Navigator.of(context).push(_createRoute(inv));
  }

  /// 👇 Hiệu ứng slide chuyển sang trang chi tiết
  Route _createRoute(Invoice inv) {
    return PageRouteBuilder(
      pageBuilder:
          (context, animation, secondaryAnimation) =>
              InvoiceDetailScreen(invoice: inv),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // trượt từ phải sang
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        final tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: '📄 Danh sách hóa đơn',
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadInvoices,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child:
                      _invoices.isEmpty
                          ? const Center(
                            child: Text(
                              'Chưa có hóa đơn nào',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                          : ListView.builder(
                            itemCount: _invoices.length,
                            itemBuilder: (context, i) {
                              final inv = _invoices[i];
                              return InkWell(
                                onTap: () => _navigateToDetail(inv),
                                borderRadius: BorderRadius.circular(12),
                                child: Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    leading: Container(
                                      height: 48,
                                      width: 48,
                                      decoration: BoxDecoration(
                                        color: Colors.teal.shade50,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.receipt_long,
                                        color: Colors.teal,
                                      ),
                                    ),
                                    title: Text(
                                      'Hóa đơn #${inv.invoiceId}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text(
                                          'Ngày: ${inv.invoiceDate.toLocal().toString().substring(0, 16)}',
                                          style: const TextStyle(
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          'Tổng: ${inv.totalAmount.toStringAsFixed(0)} ₫',
                                          style: const TextStyle(
                                            color: Colors.teal,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          'Thanh toán: ${inv.paymentMethod}',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.redAccent,
                                      ),
                                      onPressed:
                                          () => _deleteInvoice(inv.invoiceId),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                ),
              ),
    );
  }
}
