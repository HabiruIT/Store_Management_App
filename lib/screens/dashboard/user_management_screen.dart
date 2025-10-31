import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:store_manament/models/user_model.dart';
import 'package:store_manament/service/api/user_service.dart';
import 'package:store_manament/widgets/app_scaffold.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final _userService = UserService();
  final _searchCtrl = TextEditingController();
  List<UserModel> _users = [];
  List<UserModel> _filtered = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      setState(() => _loading = true);
      final users = await _userService.fetchUsers();
      setState(() {
        _users = users;
        _filtered = users;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi tải dữ liệu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _search(String query) {
    final lower = query.toLowerCase();
    setState(() {
      _filtered =
          _users.where((u) {
            return u.fullName.toLowerCase().contains(lower) ||
                u.email.toLowerCase().contains(lower);
          }).toList();
    });
  }

  Future<void> _editUser(UserModel user) async {
    log('Editing user: ${user.id}');
    final result = await showDialog(
      context: context,
      builder: (_) => _EditUserDialog(user: user, service: _userService),
    );

    if (result == true) _loadUsers();
  }

  Future<void> _deleteUser(String id) async {
    final confirm = await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: const Text(
              'Bạn có chắc chắn muốn xóa tài khoản này không?',
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
        await _userService.deleteUser(id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xóa thành công'),
            backgroundColor: Colors.green,
          ),
        );
        _loadUsers();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Quản lý nhân viên',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchCtrl,
              onChanged: _search,
              decoration: InputDecoration(
                labelText: 'Tìm kiếm nhân viên...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child:
                  _loading
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                        onRefresh: _loadUsers,
                        child:
                            _filtered.isEmpty
                                ? const Center(child: Text('Không có dữ liệu'))
                                : ListView.builder(
                                  itemCount: _filtered.length,
                                  itemBuilder: (context, i) {
                                    final u = _filtered[i];
                                    return Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.teal.shade100,
                                          child: Icon(
                                            u.gender
                                                ? Icons.male
                                                : Icons.female,
                                            color: Colors.teal,
                                          ),
                                        ),
                                        title: Text(
                                          u.fullName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        subtitle: Text(
                                          '${u.email}\n${u.phone} - ${u.address}',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        trailing: PopupMenuButton<String>(
                                          onSelected: (v) {
                                            if (v == 'edit') _editUser(u);
                                            if (v == 'delete')
                                              _deleteUser(u.id);
                                          },
                                          itemBuilder:
                                              (context) => const [
                                                PopupMenuItem(
                                                  value: 'edit',
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.edit,
                                                        size: 18,
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text('Chỉnh sửa'),
                                                    ],
                                                  ),
                                                ),
                                                PopupMenuItem(
                                                  value: 'delete',
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.delete,
                                                        size: 18,
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text('Xóa'),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ✏️ Dialog chỉnh sửa thông tin nhân viên
class _EditUserDialog extends StatefulWidget {
  final UserModel user;
  final UserService service;

  const _EditUserDialog({required this.user, required this.service});

  @override
  State<_EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<_EditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _salaryCtrl;
  DateTime? _dob;
  bool _gender = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _nameCtrl = TextEditingController(text: u.fullName);
    _addressCtrl = TextEditingController(text: u.address);
    _phoneCtrl = TextEditingController(text: u.phone);
    _salaryCtrl = TextEditingController(text: u.salary.toString());
    _dob = u.dateOfBirth;
    _gender = u.gender;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final body = {
        "fullName": _nameCtrl.text.trim(),
        "address": _addressCtrl.text.trim(),
        "phone": _phoneCtrl.text.trim(),
        "gender": _gender,
        "dateOfBirth":
            _dob?.toIso8601String() ?? DateTime.now().toIso8601String(),
        "salary": double.tryParse(_salaryCtrl.text) ?? 0,
      };
      await widget.service.updateUser(widget.user.id, body);
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật thành công'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text('Chỉnh sửa nhân viên'),
      content: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Họ và tên',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? 'Không để trống' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressCtrl,
              decoration: const InputDecoration(
                labelText: 'Địa chỉ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(
                labelText: 'Số điện thoại',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<bool>(
                    value: _gender,
                    decoration: const InputDecoration(
                      labelText: 'Giới tính',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: true, child: Text('Nam')),
                      DropdownMenuItem(value: false, child: Text('Nữ')),
                    ],
                    onChanged: (v) => setState(() => _gender = v ?? true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                      _dob == null
                          ? 'Ngày sinh'
                          : DateFormat('dd/MM/yyyy').format(_dob!),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _salaryCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Lương',
                border: OutlineInputBorder(),
              ),
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
          onPressed: _loading ? null : _save,
          icon: const Icon(Icons.save),
          label: const Text('Lưu'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
        ),
      ],
    );
  }
}
