import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:store_manament/models/app_session.dart';
import '../../widgets/action_card.dart';
import '../../widgets/app_scaffold.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String get _role => AppSession.role ?? 'Admin';

  /// 💡 Danh sách action theo vai trò
  List<Map<String, dynamic>> get _actions {
    switch (_role) {
      case 'sales': // Nhân viên bán hàng
        return [
          {'icon': Icons.person, 'label': 'Thông tin NV', 'route': '/staff'},
          {'icon': Icons.point_of_sale, 'label': 'Bán hàng', 'route': '/sales'},
          {
            'icon': Icons.shopping_bag,
            'label': 'Sản phẩm',
            'route': '/products',
          },
          {'icon': Icons.receipt, 'label': 'Hóa đơn', 'route': '/invoices'},
          {
            'icon': Icons.inventory_2,
            'label': 'Tồn kho',
            'route': '/inventory',
          },
        ];

      case 'warehouse': // Nhân viên kho
        return [
          {'icon': Icons.person, 'label': 'Thông tin NV', 'route': '/staff'},
          {
            'icon': Icons.warehouse_rounded,
            'label': 'Kho hàng',
            'route': '/warehouses',
          },
          {
            'icon': Icons.inventory_2,
            'label': 'Tồn kho',
            'route': '/inventory',
          },
          {
            'icon': Icons.category,
            'label': 'Loại hàng',
            'route': '/categories',
          },
          {'icon': Icons.analytics, 'label': 'Báo cáo', 'route': '/reports'},
        ];

      default: // Admin
        return [
          {'icon': Icons.person, 'label': 'Thông tin NV', 'route': '/staff'},
          {
            'icon': Icons.point_of_sale,
            'label': 'Sản phẩm',
            'route': '/products',
          },
          {
            'icon': Icons.inventory_2,
            'label': 'Tồn kho',
            'route': '/inventory',
          },
          {'icon': Icons.point_of_sale, 'label': 'Bán hàng', 'route': '/sales'},
          {'icon': Icons.analytics, 'label': 'Báo cáo', 'route': '/reports'},
          {
            'icon': Icons.category,
            'label': 'Loại hàng',
            'route': '/categories',
          },
          {
            'icon': Icons.person_add,
            'label': 'Đăng ký NV',
            'route': '/register',
          },
          {'icon': Icons.receipt, 'label': 'Hóa đơn', 'route': '/invoices'},
          {
            'icon': Icons.warehouse_rounded,
            'label': 'Kho hàng',
            'route': '/warehouses',
          },
          {'icon': Icons.people_alt, 'label': 'Quản lý NV', 'route': '/users'},
        ];
    }
  }

  Future<void> _logout() async {
    await AppSession.clearSession();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    log('Current Role: $_role');
    return AppScaffold(
      title: 'Bảng điều khiển',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Xin chào, ${AppSession.fullName ?? 'nhân viên'} 👋',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                'Vai trò: $_role',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),

              /// 🎯 Action Cards theo vai trò
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                physics: const NeverScrollableScrollPhysics(),
                children:
                    _actions
                        .map(
                          (item) => ActionCard(
                            icon: item['icon'],
                            label: item['label'],
                            onTap:
                                () =>
                                    Navigator.pushNamed(context, item['route']),
                          ),
                        )
                        .toList(),
              ),

              const SizedBox(height: 32),

              /// 🚪 Nút Đăng xuất
              Center(
                child: ElevatedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Đăng xuất'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(180, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
