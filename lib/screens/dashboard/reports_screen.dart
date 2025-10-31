import 'package:flutter/material.dart';
import 'package:store_manament/models/invoice.dart';
import 'package:store_manament/models/invoice_detail.dart';
import 'package:store_manament/models/payment.dart';
import 'package:store_manament/models/stock_transaction.dart';
import '../../widgets/app_scaffold.dart';
import '../../utils/theme/app_color.dart';
import '../../service/api/invoice_service.dart';
import '../../service/api/invoice_detail_service.dart';
import '../../service/api/payment_service.dart';
import '../../service/api/stock_transaction_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final InvoiceService _invoiceService = InvoiceService();
  final InvoiceDetailService _detailService = InvoiceDetailService();
  final PaymentService _paymentService = PaymentService();
  final StockTransactionService _txService = StockTransactionService();

  bool _loading = true;
  String? _error;

  // data
  List<Invoice> _invoices = [];
  List<InvoiceDetail> _invoiceDetails = [];
  List<Payment> _payments = [];
  List<StockTransaction> _transactions = [];

  // computed
  double _todayRevenue = 0;
  int _todayOrders = 0;
  double _avgOrderValue = 0;
  double _profit = 0; // rough estimate using (sales - cost) if cost known (we don't have cost here) -> show 0 if unknown
  List<double> _revenueSeries7 = List.filled(7, 0);
  List<Map<String, dynamic>> _topProducts = [];
  List<StockTransaction> _recentTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Fetch main lists
      final invoices = await _invoiceService.fetchInvoices();
      final payments = <Payment>[];
      // fetch payments for invoices (or get all by calling payments endpoint per invoice)
      for (final inv in invoices) {
        try {
          final ps = await _paymentService.fetchPaymentsByInvoice(inv.invoiceId);
          payments.addAll(ps);
        } catch (_) {
          // ignore per-invoice payment fetch errors
        }
      }

      final transactions = await _txService.fetchTransactions();

      // For top products we need invoice details of recent invoices.
      // We'll fetch details for up to latest 30 invoices to avoid heavy load.
      final details = <InvoiceDetail>[];
      final recentInvoices = invoices.take(30).toList();
      for (final inv in recentInvoices) {
        try {
          final dets = await _detailService.fetchByInvoice(inv.invoiceId);
          details.addAll(dets);
        } catch (_) {
          // skip errors per-invoice
        }
      }

      // assign
      _invoices = invoices;
      _payments = payments;
      _transactions = transactions;
      _invoiceDetails = details;

      // compute KPIs
      _computeKpis();

      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  void _computeKpis() {
    final now = DateTime.now();

    // Revenue & orders today (use invoiceDate or paymentDate depending what you prefer)
    double todayRevenue = 0;
    int todayOrders = 0;
    double totalOrderValue = 0;

    for (final inv in _invoices) {
      final invDate = inv.invoiceDate.toLocal();
      if (invDate.year == now.year &&
          invDate.month == now.month &&
          invDate.day == now.day) {
        todayOrders += 1;
        totalOrderValue += inv.totalAmount;
      }
    }
    // Revenue: sum of payments made today OR sum of invoice totals created today (choose payments if you want cash-collected)
    for (final p in _payments) {
      final pd = p.paymentDate.toLocal();
      if (pd.year == now.year && pd.month == now.month && pd.day == now.day) {
        todayRevenue += p.amount;
      }
    }
    // If no payments today, fallback to invoice totals
    if (todayRevenue == 0) {
      todayRevenue = _invoices
        .where((inv) =>
            inv.invoiceDate.toLocal().year == now.year &&
            inv.invoiceDate.toLocal().month == now.month &&
            inv.invoiceDate.toLocal().day == now.day)
        .fold(0.0, (prev, inv) => prev + inv.totalAmount);
    }

    final avgOrder = todayOrders > 0 ? (totalOrderValue / todayOrders) : 0.0;

    // revenue series last 7 days (by invoiceDate totals)
    final series = List<double>.filled(7, 0.0);
    for (final inv in _invoices) {
      final diff = now.difference(inv.invoiceDate.toLocal()).inDays;
      if (diff >= 0 && diff < 7) {
        // index 6 = today, index 0 = 6 days ago; we want [6daysAgo,...,today] or the reverse; we'll build Mon..Sun with today last.
        final idx = 6 - diff;
        series[idx] = series[idx] + inv.totalAmount;
      }
    }

    // top products aggregation from invoiceDetails
    final Map<int, Map<String, dynamic>> agg = {}; // productId -> {name, qty, revenue}
    for (final d in _invoiceDetails) {
      final pid = d.productId;
      final name = d.productName;
      final qty = d.quantity;
      final revenue = d.lineTotal;
      final entry = agg.putIfAbsent(pid, () => {'productId': pid, 'name': name, 'qty': 0, 'revenue': 0.0});
      entry['qty'] = (entry['qty'] as int) + qty;
      entry['revenue'] = (entry['revenue'] as double) + revenue;
    }
    final top = agg.values.toList()
      ..sort((a, b) => (b['qty'] as int).compareTo(a['qty'] as int));
    final topProducts = top.take(6).map((e) => {
          'productId': e['productId'],
          'name': e['name'],
          'sold': e['qty'],
          'revenue': e['revenue'],
        }).toList();

    // recent transactions
    final recentTx = List<StockTransaction>.from(_transactions)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final recentTransactions = recentTx.take(6).toList();

    // profit estimate: if invoice has no cost info, set to zero. We'll attempt best-effort:
    double profit = 0;
    // If Invoice model had cost, we'd compute. Keep 0.

    // assign to state fields
    _todayRevenue = todayRevenue;
    _todayOrders = todayOrders;
    _avgOrderValue = avgOrder;
    _profit = profit;
    _revenueSeries7 = series;
    _topProducts = topProducts;
    _recentTransactions = recentTransactions;
  }

  Widget _kpiCard(String label, String value, IconData icon, Color color) {
    return SizedBox(
      width: 180,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    const SizedBox(height: 6),
                    Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCurrency(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Báo cáo',
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Lỗi: $_error'))
              : RefreshIndicator(
                  onRefresh: _loadReports,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tổng quan', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _kpiCard('Doanh thu hôm nay', '\$${_formatCurrency(_todayRevenue)}', Icons.show_chart, AppColor.main),
                            _kpiCard('Đơn trong ngày', '$_todayOrders', Icons.receipt_long, AppColor.generateColorPalette(3)),
                            _kpiCard('Giá trị TB đơn', '\$${_avgOrderValue.toStringAsFixed(0)}', Icons.attach_money, AppColor.generateColorPalette(5)),
                            _kpiCard('Lợi nhuận (ước)', '\$${_profit.toStringAsFixed(0)}', Icons.trending_up, AppColor.generateColorPalette(10)),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Revenue chart card
                        Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Biểu đồ doanh thu 7 ngày', style: TextStyle(fontWeight: FontWeight.w600)),
                                    Text('Tuần gần nhất', style: Theme.of(context).textTheme.bodyMedium),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 160,
                                  child: _SimpleBarChart(series: _revenueSeries7, color: AppColor.main),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Text('6 ngày trước'),
                                    Text('5 ngày'),
                                    Text('4 ngày'),
                                    Text('3 ngày'),
                                    Text('2 ngày'),
                                    Text('Hôm qua'),
                                    Text('Hôm nay'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Top products and recent transactions side by side (responsive)
                        LayoutBuilder(builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 700;
                          return isWide
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: _buildTopProductsCard()),
                                    const SizedBox(width: 12),
                                    Expanded(child: _buildRecentTransactionsCard()),
                                  ],
                                )
                              : Column(
                                  children: [
                                    _buildTopProductsCard(),
                                    const SizedBox(height: 12),
                                    _buildRecentTransactionsCard(),
                                  ],
                                );
                        }),

                        const SizedBox(height: 20),

                        // Recent invoices table (last 10)
                        Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Hóa đơn gần đây', style: TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columns: const [
                                      DataColumn(label: Text('Mã')),
                                      DataColumn(label: Text('Khách hàng')),
                                      DataColumn(label: Text('Ngày')),
                                      DataColumn(label: Text('Tổng tiền')),
                                      DataColumn(label: Text('Phương thức')),
                                      DataColumn(label: Text('Trạng thái')),
                                    ],
                                    rows: _invoices.take(10).map((inv) {
                                      return DataRow(cells: [
                                        DataCell(Text('#${inv.invoiceId}')),
                                        DataCell(Text(inv.customerName)),
                                        DataCell(Text(inv.invoiceDate.toLocal().toString().substring(0, 16))),
                                        DataCell(Text('\$${inv.totalAmount.toStringAsFixed(0)}')),
                                        DataCell(Text(inv.paymentMethod)),
                                        DataCell(Text(inv.status)),
                                      ]);
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildTopProductsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Sản phẩm bán chạy', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          if (_topProducts.isEmpty)
            const Text('Không có dữ liệu')
          else
            Column(
              children: _topProducts.map((p) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(p['name'] as String),
                  subtitle: Text('Đã bán: ${p['sold']} • Doanh thu: \$${(p['revenue'] as double).toStringAsFixed(0)}'),
                  trailing: Text('#${p['productId']}'),
                );
              }).toList(),
            ),
        ]),
      ),
    );
  }

  Widget _buildRecentTransactionsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Giao dịch kho gần đây', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          if (_recentTransactions.isEmpty)
            const Text('Không có giao dịch')
          else
            Column(
              children: _recentTransactions.map((t) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    t.transactionType.toLowerCase() == 'nhap' ? Icons.arrow_downward : Icons.arrow_upward,
                    color: t.transactionType.toLowerCase() == 'nhap' ? Colors.green : Colors.red,
                  ),
                  title: Text('${t.transactionType} • ${t.productName}'),
                  subtitle: Text('Kho: ${t.warehouseId} • ${t.createdBy}'),
                  trailing: Text('${t.quantity}'),
                );
              }).toList(),
            ),
        ]),
      ),
    );
  }
}

/// Small bar chart used in the UI
class _SimpleBarChart extends StatelessWidget {
  final List<double> series;
  final Color color;

  const _SimpleBarChart({required this.series, required this.color});

  @override
  Widget build(BuildContext context) {
    final max = series.isNotEmpty ? series.reduce((a, b) => a > b ? a : b) : 1.0;
    final bars = series.map((v) {
      final h = max == 0 ? 0.0 : (v / max) * 120;
      return Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              height: h,
              width: 14,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 6),
            // label could go here
          ],
        ),
      );
    }).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: bars,
    );
  }
}
