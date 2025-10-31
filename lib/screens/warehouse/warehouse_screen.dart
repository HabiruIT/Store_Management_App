import 'package:flutter/material.dart';
import 'package:store_manament/models/warehouse.dart';
import 'package:store_manament/service/api/warehouse_service.dart';
import 'package:store_manament/widgets/app_scaffold.dart';

class WarehouseScreen extends StatefulWidget {
  const WarehouseScreen({super.key});

  @override
  State<WarehouseScreen> createState() => _WarehouseScreenState();
}

class _WarehouseScreenState extends State<WarehouseScreen> {
  final WarehouseService _service = WarehouseService();
  late Future<List<Warehouse>> _futureWarehouses;

  @override
  void initState() {
    super.initState();
    _futureWarehouses = _service.fetchWarehouses();
  }

  Future<void> _refresh() async {
    setState(() {
      _futureWarehouses = _service.fetchWarehouses();
    });
  }

  void _showSnack(String msg, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color ?? Colors.black87),
    );
  }

  void _openForm({Warehouse? warehouse}) async {
    final result = await showDialog(
      context: context,
      builder: (context) => _WarehouseFormDialog(warehouse: warehouse),
    );
    if (result == true) _refresh();
  }

  Future<void> _deleteWarehouse(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: const Text(
              'Bạn có chắc chắn muốn xóa kho hàng này không?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Xóa'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        final msg = await _service.deleteWarehouse(id);
        _showSnack(msg, color: Colors.green);
        _refresh();
      } catch (_) {
        _showSnack('Xóa kho thất bại', color: Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Quản lý kho hàng',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        label: const Text('Thêm kho'),
        icon: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Warehouse>>(
          future: _futureWarehouses,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(
                child: Text('Không thể tải danh sách kho 😢'),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Chưa có kho hàng nào'));
            }

            final warehouses = snapshot.data!;
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: warehouses.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, i) {
                final w = warehouses[i];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal.shade100,
                      child: const Icon(Icons.warehouse, color: Colors.teal),
                    ),
                    title: Text(
                      w.warehouseName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Vị trí: ${w.location}'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) {
                        if (v == 'edit') _openForm(warehouse: w);
                        if (v == 'delete') _deleteWarehouse(w.warehouseId);
                      },
                      itemBuilder:
                          (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Sửa'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Xóa'),
                            ),
                          ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// 📦 Dialog thêm / sửa kho hàng
class _WarehouseFormDialog extends StatefulWidget {
  final Warehouse? warehouse;
  const _WarehouseFormDialog({this.warehouse});

  @override
  State<_WarehouseFormDialog> createState() => _WarehouseFormDialogState();
}

class _WarehouseFormDialogState extends State<_WarehouseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _service = WarehouseService();
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.warehouse != null) {
      _nameCtrl.text = widget.warehouse!.warehouseName;
      _locationCtrl.text = widget.warehouse!.location;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final body = {
      "warehouseName": _nameCtrl.text.trim(),
      "location": _locationCtrl.text.trim(),
    };

    try {
      if (widget.warehouse == null) {
        await _service.createWarehouse(body);
        Navigator.pop(context, true);
      } else {
        await _service.updateWarehouse(widget.warehouse!.warehouseId, body);
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lưu thất bại'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.warehouse != null;

    return AlertDialog(
      scrollable: true, // ✅ Cho phép cuộn nội dung khi bàn phím mở
      title: Text(isEdit ? 'Cập nhật kho hàng' : 'Thêm kho hàng mới'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Tên kho hàng',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? 'Nhập tên kho hàng' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _locationCtrl,
              decoration: const InputDecoration(
                labelText: 'Vị trí',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? 'Nhập vị trí' : null,
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
          label: Text(isEdit ? 'Cập nhật' : 'Thêm mới'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
        ),
      ],
    );
  }
}
