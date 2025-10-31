import 'package:flutter/material.dart';
import '../utils/theme/app_color.dart';

class StoreAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const StoreAppBar({super.key, this.title = '', this.actions});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: preferredSize,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: AppColor.gardientAppbar),
          boxShadow: [
            BoxShadow(color: AppColor.shadow.withOpacity(0.2), blurRadius: 6),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: kToolbarHeight,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Stack(
              children: [
                // Centered title
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Leading: automatic back button when possible
                Align(
                  alignment: Alignment.centerLeft,
                  child: Builder(
                    builder: (ctx) {
                      final canPop = Navigator.of(ctx).canPop();
                      if (!canPop) return const SizedBox.shrink();
                      return IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(ctx).maybePop(),
                        tooltip:
                            MaterialLocalizations.of(ctx).backButtonTooltip,
                      );
                    },
                  ),
                ),
                // Actions on the right
                if (actions != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: actions!,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
