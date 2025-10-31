import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:store_manament/models/app_session.dart';
import 'package:store_manament/screens/dashboard/user_management_screen.dart';
import 'package:store_manament/screens/invoice/invoice_screen.dart';
import 'package:store_manament/screens/warehouse/warehouse_screen.dart';
import 'utils/theme/app_color.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/product/products_screen.dart';
import 'screens/inventory/inventory_screen.dart';
import 'screens/staff/staff_profile_screen.dart';
import 'screens/dashboard/reports_screen.dart';
import 'screens/category/category_screen.dart';
import 'screens/authenticate/register_screen.dart';
import 'screens/authenticate/login_screen.dart';
import 'screens/sales/sales_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await AppSession.loadSession();

  runApp(MyApp(isLoggedIn: AppSession.isLoggedIn));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.isLoggedIn});

  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quản lý cửa hàng',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColor.main),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColor.background,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColor.gardientAppbar.first,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.main,
            foregroundColor: Colors.white,
          ),
        ),
      ),

      /// ✅ Thiết lập luồng điều hướng
      initialRoute: isLoggedIn ? '/dashboard' : '/login',
      routes: {
        '/dashboard': (context) => const DashboardScreen(),
        '/products': (context) => const ProductsScreen(),
        '/inventory': (context) => const InventoryScreen(),
        '/invoices': (context) => const InvoiceScreen(),
        '/staff': (context) => const StaffProfileScreen(),
        '/reports': (context) => const ReportsScreen(),
        '/categories': (context) => const CategoryScreen(),
        '/register': (context) => const RegisterScreen(),
        '/sales': (context) => const SalesScreen(),
        '/warehouses': (context) => const WarehouseScreen(),
        '/users': (context) => const UserManagementScreen(),
      },

      /// ✅ Bảo vệ route login: nếu đã login → tự vào dashboard
      onGenerateRoute: (settings) {
        if (settings.name == '/login' && AppSession.isLoggedIn) {
          return MaterialPageRoute(builder: (_) => const DashboardScreen());
        }

        if (settings.name == '/login') {
          // 🚫 Không cho quay lại Dashboard khi ở màn Login
          return MaterialPageRoute(
            builder: (_) => const LoginScreen(),
            settings: settings,
          );
        }

        return null;
      },
    );
  }
}
