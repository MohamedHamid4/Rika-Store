import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rika_store/Helpers/app_strings.dart';
import 'package:rika_store/Helpers/preference_helper.dart';
import 'package:rika_store/Views/success_screen.dart';
import 'package:provider/provider.dart';
import 'package:rika_store/ViewModel/settings_viewmodel.dart';

class SignUpViewModel extends ChangeNotifier {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isPasswordHidden = true;
  bool _isConfirmHidden = true;
  bool _isLoading = false;

  bool get isPasswordHidden => _isPasswordHidden;
  bool get isConfirmHidden => _isConfirmHidden;
  bool get isLoading => _isLoading;

  void togglePasswordVisibility() {
    _isPasswordHidden = !_isPasswordHidden;
    notifyListeners();
  }

  void toggleConfirmVisibility() {
    _isConfirmHidden = !_isConfirmHidden;
    notifyListeners();
  }

  bool _isRealEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) return false;

    List<String> trustedDomains = [
      'gmail.com',
      'yahoo.com',
      'outlook.com',
      'hotmail.com',
      'icloud.com',
      'live.com'
    ];

    String domain = email.split('@').last.toLowerCase();
    return trustedDomains.contains(domain);
  }

  Future<void> signUp(BuildContext context) async {
    final String lang = Provider.of<SettingsViewModel>(
      context,
      listen: false,
    ).appLocale.languageCode;

    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showError(context, AppStrings.get('error_empty_fields', lang));
      return;
    }

    if (!_isRealEmail(email)) {
      _showError(context, lang == 'ar'
          ? "يرجى إدخال بريد إلكتروني حقيقي (Gmail, Yahoo, etc..)"
          : "Please enter a valid real email (Gmail, Yahoo, etc..)");
      return;
    }

    if (password != confirmPassword) {
      _showError(context, AppStrings.get('error_mismatch_password', lang));
      return;
    }

    _setLoading(true);

    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await userCredential.user?.updateDisplayName(name);

      await userCredential.user?.sendEmailVerification();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              lang == 'ar'
                  ? "تم إرسال رابط التفعيل لإيميلك الحقيقي. يرجى تفعيله قبل الدخول."
                  : "Verification link sent to your real email. Please verify before login.",
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );

        await _auth.signOut();
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      _showError(context, e.message ?? "Error");
    } catch (e) {
      _showError(context, e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}