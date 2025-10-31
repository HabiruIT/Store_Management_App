import 'package:flutter/material.dart';
import 'package:store_manament/forms/product_form.dart';
import 'package:store_manament/models/product.dart';
import 'package:store_manament/service/api/product_service.dart';
import 'package:store_manament/widgets/app_scaffold.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductService _service = ProductService();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Chi tiết sản phẩm',
      body: FutureBuilder<Product?>(
        future: _service.fetchProductDetail(widget.productId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snap.hasError) {
            return const Center(
              child: Text('Không thể tải chi tiết sản phẩm 😢'),
            );
          } else if (!snap.hasData) {
            return const Center(child: Text('Không tìm thấy sản phẩm'));
          }

          final p = snap.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                /// Ảnh sản phẩm nổi bật
                Hero(
                  tag: 'product_${p.productId}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child:
                        p.imageUrl != null
                            ? Image.network(
                              p.imageUrl!,
                              height: 240,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                            : Container(
                              height: 240,
                              width: double.infinity,
                              color: Colors.grey.shade300,
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 80,
                                color: Colors.grey,
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 20),

                /// Thông tin cơ bản
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.productName,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.category_outlined,
                              color: Colors.teal.shade600,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              p.categoryName,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.square_foot_outlined,
                              color: Colors.teal,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Đơn vị: ${p.unit}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            const Icon(
                              Icons.sell_outlined,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Giá bán: ${p.price.toStringAsFixed(0)}₫',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.payments_outlined,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Giá vốn: ${p.costPrice.toStringAsFixed(0)}₫',
                              style: const TextStyle(fontSize: 17),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              p.status ? Icons.check_circle : Icons.cancel,
                              color: p.status ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              p.status ? 'Đang kinh doanh' : 'Ngừng kinh doanh',
                              style: TextStyle(
                                color:
                                    p.status ? Colors.green : Colors.redAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                /// Hành động nhanh
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        minimumSize: const Size(130, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.edit),
                      label: const Text('Sửa'),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductFormScreen(product: p),
                          ),
                        );

                        // Nếu form trả về true (đã cập nhật thành công), reload lại chi tiết
                        if (result == true && context.mounted) {
                          setState(
                            () {},
                          ); // gọi lại FutureBuilder để refresh sản phẩm
                        }
                      },
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        minimumSize: const Size(130, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.delete),
                      label: const Text('Xóa'),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('Xác nhận xóa'),
                                content: Text(
                                  'Bạn có chắc chắn muốn xóa "${p.productName}" không?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                    child: const Text('Hủy'),
                                  ),
                                  ElevatedButton(
                                    onPressed:
                                        () => Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text('Xóa'),
                                  ),
                                ],
                              ),
                        );
                        if (confirm == true) {
                          await _service.deleteProduct(p.productId);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã xóa sản phẩm'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            Navigator.pop(context);
                          }
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  label: const Text('Quay lại danh sách'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
