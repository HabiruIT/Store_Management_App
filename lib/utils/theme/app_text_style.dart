import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:store_manament/utils/theme/app_color.dart';

class AppTextStyle {
  static TextStyle h1 = GoogleFonts.quicksand(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    textStyle: TextStyle(overflow: TextOverflow.ellipsis),
  );

  static TextStyle h2 = GoogleFonts.quicksand(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static TextStyle h3 = GoogleFonts.quicksand(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static TextStyle body = GoogleFonts.quicksand(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static TextStyle bodyTiny = GoogleFonts.quicksand(
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  static TextStyle bodyMedium = GoogleFonts.quicksand(
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  static TextStyle bodyDimmed = GoogleFonts.quicksand(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColor.dimmedText,
  );

  static TextStyle bodyLarge = GoogleFonts.quicksand(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static TextStyle buttonLarge = GoogleFonts.quicksand(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  static TextStyle withWeight(TextStyle style, FontWeight fontWeight) {
    return style.copyWith(fontWeight: fontWeight);
  }

  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
}
