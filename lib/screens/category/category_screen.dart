import 'package:flutter/material.dart';
import 'package:store_manament/models/category.dart';
import '../../widgets/app_scaffold.dart';
import '../../service/api/category_service.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final CategoryService _service = CategoryService();
  List<Category> _categories = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _service.fetchCategories();
      if (!mounted) return;
      setState(() => _categories = list);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _showEditDialog({Category? initial}) {
    final scaffoldContext = context; // 🔒 Lưu context an toàn
    final controller = TextEditingController(text: initial?.categoryName ?? '');

    showDialog(
      context: scaffoldContext,
      builder: (dialogContext) => AlertDialog(
        title: Text(initial == null ? 'Thêm loại hàng' : 'Sửa loại hàng'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Tên loại hàng'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isEmpty) return;

              // Đóng dialog
              Navigator.pop(dialogContext);

              // Đảm bảo widget chưa bị huỷ
              if (!mounted) return;

              // Dùng context gốc của Scaffold, không phải dialog
              ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                const SnackBar(content: Text('Đang xử lý...')),
              );

              try {
                if (initial == null) {
                  final created = await _service.createCategory(text);
                  if (!mounted) return;

                  if (created.categoryId != -1) {
                    setState(() => _categories.add(created));
                    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                      const SnackBar(content: Text('Thêm thành công')),
                    );
                  } else {
                    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                      const SnackBar(content: Text('Thêm thất bại')),
                    );
                  }
                } else {
                  await _service.updateCategory(initial.categoryId, text);
                  if (!mounted) return;

                  setState(() {
                    final idx = _categories.indexWhere(
                      (c) => c.categoryId == initial.categoryId,
                    );
                    if (idx >= 0) {
                      _categories[idx] = Category(
                        categoryId: initial.categoryId,
                        categoryName: text,
                      );
                    }
                  });
                  ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                    const SnackBar(content: Text('Cập nhật thành công')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                    SnackBar(content: Text('Lỗi: $e')),
                  );
                }
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(Category c) async {
    final scaffoldContext = context; // 🔒 Lưu context gốc
    final ok = await showDialog<bool>(
      context: scaffoldContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận'),
        content: Text('Bạn có muốn xoá "${c.categoryName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
      const SnackBar(content: Text('Đang xoá...')),
    );

    await _service.deleteCategory(c.categoryId);
    if (!mounted) return;

    setState(() {
      _categories.removeWhere((x) => x.categoryId == c.categoryId);
    });

    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
      const SnackBar(content: Text('Đã xoá')),
    );
  }

  @override
  void dispose() {
    // Đảm bảo service không gọi context bên trong dispose()
    try {
      _service.dispose();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Loại hàng',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showEditDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm loại hàng'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _loadCategories,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tải lại'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              Expanded(child: Center(child: Text('Lỗi: $_error')))
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, i) {
                    final c = _categories[i];
                    return ListTile(
                      title: Text(c.categoryName),
                      leading: CircleAvatar(
                        child: Text(
                          c.categoryName.isNotEmpty
                              ? c.categoryName[0]
                              : '?',
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => _showEditDialog(initial: c),
                            icon: const Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () => _deleteCategory(c),
                            icon: const Icon(Icons.delete, color: Colors.red),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
