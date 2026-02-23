import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rika_store/AppTheme/app_colors.dart';
import 'package:rika_store/Helpers/app_strings.dart';
import 'package:rika_store/ViewModel/settings_viewmodel.dart';

class AppDialogs {
  static void showNetworkError(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final String lang = Provider.of<SettingsViewModel>(context, listen: false).appLocale.languageCode;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.primaryNavy : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.wifi_off_rounded, size: 50, color: Colors.red),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.get('no_connection', lang), // ترجمة العنوان
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              AppStrings.get('check_internet', lang), // ترجمة الرسالة
              textAlign: TextAlign.center,
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppStrings.get('retry', lang),
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.primaryNavy,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}