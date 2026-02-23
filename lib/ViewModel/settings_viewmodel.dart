import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rika_store/Helpers/preference_helper.dart';

class SettingsViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static Locale _getInitialLocale() {
    String? savedLang = PreferenceHelper.getLanguage();
    if (savedLang == null || savedLang.isEmpty) {
      return WidgetsBinding.instance.platformDispatcher.locale;
    }
    return Locale(savedLang);
  }

  Locale _appLocale = _getInitialLocale();
  Locale get appLocale => _appLocale;

  String get selectedLanguage =>
      _appLocale.languageCode == 'en' ? 'English' : 'العربية';

  void changeLanguage(String languageCode) async {
    _appLocale = Locale(languageCode);
    await PreferenceHelper.setLanguage(languageCode);
    notifyListeners();
  }

  void setLanguage(String language) {
    if (language == "العربية") {
      changeLanguage('ar');
    } else {
      changeLanguage('en');
    }
  }

  static ThemeMode _getInitialThemeMode() {
    bool? savedTheme = PreferenceHelper.getThemeStatus();

    if (savedTheme == null) {
      return ThemeMode.system;
    }

    return savedTheme ? ThemeMode.dark : ThemeMode.light;
  }

  ThemeMode _themeMode = _getInitialThemeMode();
  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme(bool value) async {
    _themeMode = value ? ThemeMode.dark : ThemeMode.light;
    await PreferenceHelper.setThemeStatus(value);
    notifyListeners();
  }

  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;

  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  bool get isAuthenticated => _auth.currentUser != null;

  String get userEmail =>
      _auth.currentUser?.email ?? PreferenceHelper.getUserEmail();

  String get userName =>
      _auth.currentUser?.displayName ?? PreferenceHelper.getUserName();

  Future<void> logout() async {
    try {
      await _auth.signOut();
      await PreferenceHelper.logOut();
      notifyListeners();
    } catch (e) {
      debugPrint("خطأ أثناء تسجيل الخروج: $e");
    }
  }
}