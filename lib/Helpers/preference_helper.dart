import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHelper {
  static late SharedPreferences _prefs;

  // مفاتيح التخزين
  static const String _isLoggedIn = "isLoggedIn";
  static const String _userName = "userName";
  static const String _userAge = "userAge";
  static const String _userImage = "userImage";
  static const String _language = "language";
  static const String _isDarkMode = "isDarkMode";
  static const String _isFirstTime = "isFirstTime";
  static const String _userEmail = "userEmail";
  static const String _userGender = "userGender";

  // تهيئة الشيرد برفرنس
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- إعدادات اللغة ---
  static Future<void> setLanguage(String langCode) async =>
      await _prefs.setString(_language, langCode);

  // تم التعديل ليعيد null بدلاً من "ar" افتراضياً
  static String? getLanguage() {
    return _prefs.getString(_language);
  }

  // --- إعدادات الثيم ---
  static Future<void> setThemeStatus(bool isDark) async {
    await _prefs.setBool(_isDarkMode, isDark);
  }

  // تم التعديل ليعيد bool? بدلاً من false افتراضياً
  static bool? getThemeStatus() {
    if (!_prefs.containsKey(_isDarkMode)) return null;
    return _prefs.getBool(_isDarkMode);
  }

  // --- إعدادات المستخدم والبيانات الشخصية ---
  static Future<void> setLoginStatus(bool value) async =>
      await _prefs.setBool(_isLoggedIn, value);

  static bool getLoginStatus() => _prefs.getBool(_isLoggedIn) ?? false;

  static Future<void> saveUserData({
    String? name,
    int? age,
    String? image,
    String? email,
    String? gender,
  }) async {
    if (name != null) await _prefs.setString(_userName, name);
    if (age != null) await _prefs.setInt(_userAge, age);
    if (image != null) await _prefs.setString(_userImage, image);
    if (email != null) await _prefs.setString(_userEmail, email);
    if (gender != null) await _prefs.setString(_userGender, gender);
  }

  static String getUserName() => _prefs.getString(_userName) ?? "";

  static int getUserAge() => _prefs.getInt(_userAge) ?? 0;

  static String getUserImage() => _prefs.getString(_userImage) ?? "";

  static String getUserEmail() => _prefs.getString(_userEmail) ?? "";

  static String getUserGender() => _prefs.getString(_userGender) ?? "male";

  // --- إعدادات التشغيل الأول ---
  static Future<void> setFirstTime(bool value) async =>
      await _prefs.setBool(_isFirstTime, value);

  static bool isFirstTime() => _prefs.getBool(_isFirstTime) ?? true;

  // --- تسجيل الخروج ---
  static Future<void> logOut() async {
    // نحذف بيانات المستخدم فقط ونبقي على إعدادات اللغة والثيم
    await _prefs.remove(_isLoggedIn);
    await _prefs.remove(_userName);
    await _prefs.remove(_userEmail);
    await _prefs.remove(_userImage);
    await _prefs.remove(_userAge);
    await _prefs.remove(_userGender);

    await setFirstTime(false);
  }
}