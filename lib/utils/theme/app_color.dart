import 'package:flutter/material.dart';

class AppColor {
  static Color main = Color(0xFF34C759);
  static Color background = Color(0xFFF0F8F0);
  static Color dimmedButton = Color(0xFFE9E9E9);
  static Color dimmedText = Color(0xFF878787);
  static Color shadow = Color(0xFFD6D6D6);
  static List<Color> gardientAppbar = [Color(0xFF19612B), Color(0xFF34C759)];

  static Color generateColorPalette(int order) {
    switch (order % 11) {
      case 0:
        return const Color(0xFFFF9800);
      case 1:
        return const Color(0xFFFBC02D);
      case 2:
        return const Color(0xFF8BC34A);
      case 3:
        return const Color(0xFF2E7D32);
      case 4:
        return const Color(0xFF009688);
      case 5:
        return const Color(0xFF00BCD4);
      case 6:
        return const Color(0xFF1976D2);
      case 7:
        return const Color(0xFF0022FF);
      case 8:
        return const Color(0xFF6A1B9A);
      case 9:
        return const Color(0xFFE91E63);
      case 10:
        return const Color(0xFFC62828);
      default:
        return Colors.grey;
    }
  }
}
