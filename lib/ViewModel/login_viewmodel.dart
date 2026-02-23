import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rika_store/Helpers/app_strings.dart';
import 'package:rika_store/Helpers/preference_helper.dart';
import 'package:rika_store/Views/navigation_bar_screen.dart';
import 'package:rika_store/ViewModel/settings_viewmodel.dart';

class LoginViewModel extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isPasswordHidden = true;

  bool get isPasswordHidden => _isPasswordHidden;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void togglePasswordVisibility() {
    _isPasswordHidden = !_isPasswordHidden;
    notifyListeners();
  }

  Future<void> login(BuildContext context) async {
    final String lang = Provider.of<SettingsViewModel>(
      context,
      listen: false,
    ).appLocale.languageCode;
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError(context, AppStrings.get('error_empty_fields', lang));
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        await FirebaseAuth.instance.signOut();
        if (context.mounted) {
          _showError(
            context,
            lang == 'ar'
                ? "بريدك الإلكتروني غير مفعل. يرجى تفعيله من الرابط المرسل إليك."
                : "Your email is not verified. Please verify it via the link sent to you.",
          );
        }
        return;
      }

      await PreferenceHelper.setLoginStatus(true);
      await PreferenceHelper.saveUserData(email: email);

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const NavigationBarScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      _showError(context, e.message ?? "Authentication Error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(BuildContext context) async {
    final String lang = Provider.of<SettingsViewModel>(
      context,
      listen: false,
    ).appLocale.languageCode;
    String email = emailController.text.trim();

    if (email.isEmpty) {
      _showError(
        context,
        lang == 'ar' ? "أدخل بريدك الإلكتروني أولاً" : "Enter your email first",
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              lang == 'ar'
                  ? "تم إرسال رابط استعادة كلمة المرور"
                  : "Reset link sent to your email",
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError(context, e.toString());
    }
  }

  Future<void> resendVerificationEmail(BuildContext context) async {
    final String lang = Provider.of<SettingsViewModel>(
      context,
      listen: false,
    ).appLocale.languageCode;
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError(
        context,
        lang == 'ar' ? "أدخل البيانات أولاً" : "Enter credentials first",
      );
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      await userCredential.user?.sendEmailVerification();
      await FirebaseAuth.instance.signOut();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              lang == 'ar'
                  ? "تم إعادة إرسال رابط التفعيل"
                  : "Verification email resent",
            ),
          ),
        );
      }
    } catch (e) {
      _showError(context, e.toString());
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
