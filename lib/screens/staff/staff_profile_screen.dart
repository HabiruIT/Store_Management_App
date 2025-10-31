import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:store_manament/models/app_session.dart';
import 'package:store_manament/models/user_model.dart';
import 'package:store_manament/service/api/user_service.dart';
import '../../widgets/app_scaffold.dart';
import 'dart:convert';

class StaffProfileScreen extends StatefulWidget {
  const StaffProfileScreen({Key? key}) : super(key: key);

  @override
  State<StaffProfileScreen> createState() => _StaffProfileScreenState();
}

class _StaffProfileScreenState extends State<StaffProfileScreen> {
  final _service = UserService();
  UserModel? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    try {
      // 🧩 Lấy userId từ token hoặc AppSession nếu có
      final id =
          AppSession.token == null
              ? null
              : _extractUserIdFromToken(AppSession.token!);

      if (id == null) throw Exception('Không xác định được người dùng.');

      final user = await _service.fetchUserDetail(id);
      setState(() {
        _user = user;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi tải thông tin: $e')));
    }
  }

  // 🔍 Giải mã JWT để lấy userId
  String? _extractUserIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = String.fromCharCodes(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final data = Map<String, dynamic>.from(jsonDecode(payload));
      return data['UserId']?.toString();
    } catch (_) {
      return null;
    }
  }

  Future<void> _openEditDialog() async {
    if (_user == null) return;
    final nameCtl = TextEditingController(text: _user!.fullName);
    final phoneCtl = TextEditingController(text: _user!.phone);
    final addressCtl = TextEditingController(text: _user!.address);
    bool gender = _user!.gender;
    DateTime birth = _user!.dateOfBirth;
    final salaryCtl = TextEditingController(
      text: _user!.salary.toInt().toString(),
    );

    await showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: const Text('Chỉnh sửa thông tin'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameCtl,
                          decoration: const InputDecoration(
                            labelText: 'Họ tên',
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<bool>(
                          value: gender,
                          items: const [
                            DropdownMenuItem(value: true, child: Text('Nam')),
                            DropdownMenuItem(value: false, child: Text('Nữ')),
                          ],
                          onChanged:
                              (v) => setDialogState(() => gender = v ?? true),
                          decoration: const InputDecoration(
                            labelText: 'Giới tính',
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Ngày sinh'),
                          subtitle: Text(
                            DateFormat('dd/MM/yyyy').format(birth),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: birth,
                                firstDate: DateTime(1950),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setDialogState(() => birth = picked);
                              }
                            },
                          ),
                        ),
                        TextField(
                          controller: phoneCtl,
                          decoration: const InputDecoration(
                            labelText: 'Số điện thoại',
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: addressCtl,
                          decoration: const InputDecoration(
                            labelText: 'Địa chỉ',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: salaryCtl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Lương'),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hủy'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final body = {
                          'fullName': nameCtl.text.trim(),
                          'phone': phoneCtl.text.trim(),
                          'address': addressCtl.text.trim(),
                          'gender': gender,
                          'dateOfBirth': birth.toIso8601String(),
                          'salary': int.tryParse(salaryCtl.text) ?? 0,
                        };

                        try {
                          final msg = await _service.updateUser(
                            _user!.id,
                            body,
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(msg),
                                backgroundColor: Colors.green,
                              ),
                            );
                            _fetchUser(); // Cập nhật lại dữ liệu
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Cập nhật thất bại: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: const Text('Lưu'),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> _logout() async {
    await AppSession.clearSession();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_user == null) {
      return const Scaffold(
        body: Center(child: Text('Không thể tải thông tin nhân viên')),
      );
    }

    return AppScaffold(
      title: 'Thông tin nhân viên',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(radius: 36, child: Icon(Icons.person)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_user!.fullName}\n(${_user!.email})',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('Giới tính: ${_user!.gender ? "Nam" : "Nữ"}'),
                      Text(
                        'Ngày sinh: ${DateFormat('dd/MM/yyyy').format(_user!.dateOfBirth)}',
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _openEditDialog,
                  icon: const Icon(Icons.edit),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ListTile(
              leading: const Icon(Icons.home),
              title: Text('Địa chỉ: ${_user!.address}'),
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: Text('SĐT: ${_user!.phone}'),
            ),
            ListTile(
              leading: const Icon(Icons.monetization_on),
              title: Text(
                'Lương: ${_user!.salary.toStringAsFixed(0)} ₫',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Đăng xuất'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
