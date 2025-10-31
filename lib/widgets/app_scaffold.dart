import 'package:flutter/material.dart';
import '../utils/theme/app_color.dart';
import 'store_app_bar.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final String title;
  final List<Widget>? actions;

  const AppScaffold({
    super.key,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.title = '',
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          title.isNotEmpty
              ? StoreAppBar(title: title, actions: actions)
              : AppBar(
                centerTitle: true,
                title: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                actions: actions,
                elevation: 0.5,
              ),
      body: SafeArea(child: Container(color: AppColor.background, child: body)),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
