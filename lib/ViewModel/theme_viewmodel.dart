import 'package:flutter/material.dart';
import 'package:rika_store/Helpers/preference_helper.dart';

class ThemeViewModel extends ChangeNotifier {
  ThemeMode _themeMode = _getInitialTheme();

  ThemeMode get themeMode => _themeMode;

  static ThemeMode _getInitialTheme() {
    bool? isDark = PreferenceHelper.getThemeStatus();
    if (isDark == null) return ThemeMode.system;
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

    await PreferenceHelper.setThemeStatus(isDark);

    notifyListeners();
  }
}
