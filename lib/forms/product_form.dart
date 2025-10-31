import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:store_manament/models/category.dart';
import 'package:store_manament/models/product.dart';
import '../../service/api/product_service.dart';
import '../../service/api/category_service.dart';
import '../../widgets/app_scaffold.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;
  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = ProductService();
  final _categoryService = CategoryService();

  final _nameCtrl = TextEditingController();
  final _unitCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _barcodeCtrl = TextEditingController();

  int? _categoryId;
  bool _status = true;
  File? _image;
  bool _loadingCategories = true;
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();

    if (widget.product != null) {
      final p = widget.product!;
      _nameCtrl.text = p.productName;
      _unitCtrl.text = p.unit;
      _priceCtrl.text = p.price.toStringAsFixed(0);
      _costCtrl.text = p.costPrice.toStringAsFixed(0);
      _barcodeCtrl.text = "";
      _status = p.status;
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final cats = await _categoryService.fetchCategories();
      setState(() {
        _categories = cats;
        _loadingCategories = false;

        // nếu đang edit thì tự động chọn đúng danh mục
        if (widget.product != null) {
          final match = cats.firstWhere(
            (c) => c.categoryName == widget.product!.categoryName,
            orElse: () => cats.first,
          );
          _categoryId = match.categoryId;
        }
      });
    } catch (e) {
      setState(() => _loadingCategories = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể tải danh mục'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      _showSnack('Vui lòng chọn danh mục', Colors.orange);
      return;
    }

    final body = {
      "productName": _nameCtrl.text.trim(),
      "categoryId": _categoryId!,
      "unit": _unitCtrl.text.trim(),
      "price": double.tryParse(_priceCtrl.text) ?? 0,
      "costPrice": double.tryParse(_costCtrl.text) ?? 0,
      "barcode": _barcodeCtrl.text.trim(),
      "status": _status,
    };

    try {
      if (widget.product == null) {
        final created = await _service.createProduct(body);
        if (_image != null)
          await _service.uploadImage(created.productId, _image!);
        _showSnack('Thêm sản phẩm thành công', Colors.green);
      } else {
        await _service.updateProduct(widget.product!.productId, body);
        if (_image != null) {
          await _service.uploadImage(widget.product!.productId, _image!);
        }
        _showSnack('Cập nhật sản phẩm thành công', Colors.green);
      }
      if (context.mounted) Navigator.pop(context, true);
    } catch (e) {
      _showSnack('Lưu thất bại', Colors.red);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return AppScaffold(
      title: isEdit ? 'Cập nhật sản phẩm' : 'Thêm sản phẩm',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tên sản phẩm',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Nhập tên sản phẩm' : null,
              ),
              const SizedBox(height: 12),

              /// 🎯 Dropdown chọn danh mục
              _loadingCategories
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<int>(
                    value: _categoryId,
                    items:
                        _categories
                            .map(
                              (c) => DropdownMenuItem<int>(
                                value: c.categoryId,
                                child: Text(c.categoryName),
                              ),
                            )
                            .toList(),
                    onChanged: (v) => setState(() => _categoryId = v),
                    decoration: InputDecoration(
                      labelText: 'Danh mục sản phẩm',
                      prefixIcon: const Icon(Icons.category),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                    ),
                    validator:
                        (v) => v == null ? 'Vui lòng chọn danh mục' : null,
                  ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _unitCtrl,
                decoration: const InputDecoration(
                  labelText: 'Đơn vị',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Giá bán',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _costCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Giá vốn',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _barcodeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Barcode',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              SwitchListTile(
                title: const Text('Đang kinh doanh'),
                value: _status,
                onChanged: (v) => setState(() => _status = v),
              ),
              const SizedBox(height: 12),

              /// 🖼 Hiển thị ảnh sản phẩm (ảnh gốc hoặc ảnh mới)
              Center(
                child: Column(
                  children: [
                    if (_image != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _image!,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    else if (widget.product?.imageUrl != null &&
                        widget.product!.imageUrl!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.product!.imageUrl!,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => Container(
                                height: 160,
                                width: double.infinity,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                              ),
                        ),
                      )
                    else
                      Container(
                        height: 160,
                        width: double.infinity,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Chưa có hình ảnh',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Chọn hình'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: Text(isEdit ? 'Cập nhật' : 'Thêm mới'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
