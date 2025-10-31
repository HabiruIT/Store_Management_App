import 'package:flutter/material.dart';
import 'package:store_manament/models/inventory.dart';
import 'package:store_manament/models/product.dart';
import 'package:store_manament/models/stock_transaction.dart';
import 'package:store_manament/models/warehouse.dart';
import '../../widgets/app_scaffold.dart';
import '../../service/api/inventory_service.dart';
import '../../service/api/stock_transaction_service.dart';
import '../../service/api/warehouse_service.dart';
import '../../service/api/product_service.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final InventoryService _inventoryService = InventoryService();
  final StockTransactionService _transactionService = StockTransactionService();
  final WarehouseService _warehouseService = WarehouseService();
  final ProductService _productService = ProductService();

  List<Inventory> _inventories = [];
  List<Warehouse> _warehouses = [];
  List<Product> _products = [];
  List<StockTransaction> _transactions = [];

  int? _selectedWarehouseId;
  int? _selectedProductId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final warehouses = await _warehouseService.fetchWarehouses();
      final products = await _productService.fetchProducts();
      final inventory = await _inventoryService.fetchAllInventories();
      final transactions = await _transactionService.fetchTransactions();

      setState(() {
        _warehouses = warehouses;
        _products = products;
        _inventories = inventory;
        _transactions = transactions;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể tải dữ liệu kho'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _createTransaction() async {
    final result = await showDialog(
      context: context,
      builder: (_) => _TransactionDialog(
        warehouses: _warehouses,
        products: _products,
        service: _transactionService,
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  List<Inventory> get _filteredInventories {
    return _inventories.where((inv) {
      final matchWarehouse =
          _selectedWarehouseId == null || inv.warehouseId == _selectedWarehouseId;
      final matchProduct =
          _selectedProductId == null || inv.productId == _selectedProductId;
      return matchWarehouse && matchProduct;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Quản lý kho hàng',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createTransaction,
        icon: const Icon(Icons.add),
        label: const Text('Tạo giao dịch'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Bộ lọc kho và sản phẩm
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _selectedWarehouseId,
                            hint: const Text('Chọn kho'),
                            items: _warehouses
                                .map((w) => DropdownMenuItem<int>(
                                      value: w.warehouseId,
                                      child: Text(w.warehouseName),
                                    ))
                                .toList(),
                            onChanged: (v) => setState(() => _selectedWarehouseId = v),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Kho hàng',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _selectedProductId,
                            hint: const Text('Chọn sản phẩm'),
                            items: _products
                                .map((p) => DropdownMenuItem<int>(
                                      value: p.productId,
                                      child: Text(p.productName),
                                    ))
                                .toList(),
                            onChanged: (v) => setState(() => _selectedProductId = v),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Sản phẩm',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    /// Danh sách tồn kho
                    Text(
                      'Tồn kho hiện tại',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (_filteredInventories.isEmpty)
                      const Text('Không có dữ liệu tồn kho'),
                    ..._filteredInventories.map(
                      (inv) => Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.inventory_2_outlined),
                          title: Text(inv.productName),
                          subtitle: Text('Kho: ${inv.warehouseName}'),
                          trailing: Text(
                            '${inv.quantity}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    /// Danh sách giao dịch kho gần nhất
                    Text(
                      'Giao dịch kho gần đây',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ..._transactions.take(5).map(
                      (t) => ListTile(
                        leading: Icon(
                          t.transactionType == 'Nhap'
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          color: t.transactionType == 'Nhap'
                              ? Colors.green
                              : Colors.red,
                        ),
                        title: Text('${t.transactionType} - ${t.productName}'),
                        subtitle: Text(
                            'Số lượng: ${t.quantity} | Kho: ${t.warehouseId} | ${t.createdBy}'),
                        trailing: Text(
                          '${t.createdAt.toLocal().toString().substring(0, 16)}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

/// 📦 Dialog tạo giao dịch nhập – xuất kho
class _TransactionDialog extends StatefulWidget {
  final List<Warehouse> warehouses;
  final List<Product> products;
  final StockTransactionService service;

  const _TransactionDialog({
    required this.warehouses,
    required this.products,
    required this.service,
  });

  @override
  State<_TransactionDialog> createState() => _TransactionDialogState();
}

class _TransactionDialogState extends State<_TransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  int? _warehouseId;
  int? _productId;
  String _type = 'Nhap';
  int _quantity = 0;
  final _createdByCtrl = TextEditingController();

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await widget.service.createTransaction({
        "warehouseId": _warehouseId!,
        "productId": _productId!,
        "quantity": _quantity,
        "transactionType": _type,
        "createdBy": _createdByCtrl.text.trim(),
      });
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tạo giao dịch kho thành công'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lưu thất bại'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text('Tạo giao dịch kho'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              value: _warehouseId,
              decoration: const InputDecoration(
                labelText: 'Kho hàng',
                border: OutlineInputBorder(),
              ),
              items: widget.warehouses
                  .map((w) => DropdownMenuItem<int>(
                        value: w.warehouseId,
                        child: Text(w.warehouseName),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _warehouseId = v),
              validator: (v) => v == null ? 'Chọn kho' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _productId,
              decoration: const InputDecoration(
                labelText: 'Sản phẩm',
                border: OutlineInputBorder(),
              ),
              items: widget.products
                  .map((p) => DropdownMenuItem<int>(
                        value: p.productId,
                        child: Text(p.productName),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _productId = v),
              validator: (v) => v == null ? 'Chọn sản phẩm' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(
                labelText: 'Loại giao dịch',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Nhap', child: Text('Nhập kho')),
                DropdownMenuItem(value: 'Xuat', child: Text('Xuất kho')),
              ],
              onChanged: (v) => setState(() => _type = v ?? 'Nhap'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Số lượng',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Nhập số lượng' : null,
              onChanged: (v) =>
                  _quantity = int.tryParse(v.trim()) ?? 0,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _createdByCtrl,
              decoration: const InputDecoration(
                labelText: 'Người tạo',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? 'Nhập người tạo' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save),
          label: const Text('Lưu'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
        ),
      ],
    );
  }
}
