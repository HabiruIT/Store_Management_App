import 'package:flutter/material.dart';
import 'package:store_manament/forms/product_form.dart';
import 'package:store_manament/models/product.dart';
import 'package:store_manament/screens/product/product_detal_screen.dart';
import '../../service/api/product_service.dart';
import '../../widgets/app_scaffold.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ProductService _service = ProductService();
  late Future<List<Product>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchProducts();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _service.fetchProducts();
    });
  }

  void _showSnack(String msg, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color ?? Colors.black87),
    );
  }

  Future<void> _deleteProduct(int id) async {
    try {
      final msg = await _service.deleteProduct(id);
      _showSnack(msg, color: Colors.green);
      _refresh();
    } catch (_) {
      _showSnack('Xóa sản phẩm thất bại', color: Colors.red);
    }
  }

  void _openForm({Product? product}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductFormScreen(product: product)),
    );
    if (result == true) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Quản lý sản phẩm',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        label: const Text('Thêm sản phẩm'),
        icon: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Product>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Không thể tải sản phẩm'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Chưa có sản phẩm nào'));
            }

            final products = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: products.length,
              itemBuilder: (context, i) {
                final p = products[i];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          p.imageUrl != null ? NetworkImage(p.imageUrl!) : null,
                      child:
                          p.imageUrl == null
                              ? const Icon(Icons.local_drink)
                              : null,
                    ),
                    title: Text(p.productName),
                    subtitle: Text('${p.categoryName} • ${p.unit}'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) {
                        if (v == 'edit') _openForm(product: p);
                        if (v == 'delete') _deleteProduct(p.productId);
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
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) =>
                                    ProductDetailScreen(productId: p.productId),
                          ),
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
