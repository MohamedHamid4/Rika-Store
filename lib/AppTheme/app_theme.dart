import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  // ثيم وضع النهار
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primaryNavy,
      scaffoldBackgroundColor: AppColors.lightBg,

      // هذا الجزء هو المسؤول عن تلوين الأيقونات والسيرش بار تلقائياً
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryNavy, // لون الأيقونات النشطة
        secondary: AppColors.luxuryGold, // لون التمييز
        surface: AppColors.lightSurface, // خلفية العناصر (السيرش، المنيو)
        onSurface: AppColors.primaryNavy, // لون المحتوى فوق الأسطح
      ),

      textTheme: const TextTheme(
        displayLarge:
            TextStyle(color: AppColors.lightText, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: AppColors.lightText),
        bodyMedium: TextStyle(color: AppColors.lightTextSecondary),
      ),
    );
  }

  // ثيم وضع الليل
  static ThemeData get darkTheme {
    return ThemeData(
      cardColor: AppColors.darkSurface,
      brightness: Brightness.dark,
      primaryColor: AppColors.luxuryGold,
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.luxuryGold,
        secondary: AppColors.luxuryGold,
        surface: AppColors.darkSurface,
        onSurface: AppColors.luxuryGold,
      ),
      textTheme: const TextTheme(
        displayLarge:
            TextStyle(color: AppColors.luxuryGold, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: AppColors.darkText),
        bodyMedium: TextStyle(color: AppColors.darkTextSecondary),
      ),
    );
  }
}
