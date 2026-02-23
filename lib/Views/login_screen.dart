import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rika_store/Helpers/app_strings.dart';
import 'package:rika_store/ViewModel/login_viewmodel.dart';
import 'package:rika_store/Views/signup_screen.dart';
import 'package:rika_store/ViewModel/settings_viewmodel.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final String lang = Provider.of<SettingsViewModel>(
      context,
    ).appLocale.languageCode;

    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: Consumer<LoginViewModel>(
          builder: (context, vm, child) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 120,
                        color: isDarkMode ? theme.colorScheme.secondary : null,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.shopping_bag, size: 80),
                      ),
                    ),
                    const SizedBox(height: 30),

                    Text(
                      AppStrings.get('welcome_back', lang),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode
                            ? theme.colorScheme.secondary
                            : theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 30),

                    _buildLabel(AppStrings.get('email', lang), theme),
                    _buildTextField(
                      context: context,
                      controller: vm.emailController,
                      hint: "example@gmail.com",
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 20),

                    _buildLabel(AppStrings.get('password', lang), theme),
                    _buildTextField(
                      context: context,
                      controller: vm.passwordController,
                      hint: "••••",
                      icon: Icons.lock_outline,
                      isPassword: true,
                      obscureText: vm.isPasswordHidden,
                      onIconTap: () => vm.togglePasswordVisibility(),
                    ),

                    Align(
                      alignment: lang == 'ar'
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => vm.resetPassword(context),
                        child: Text(
                          lang == 'ar'
                              ? "نسيت كلمة المرور؟"
                              : "Forgot Password?",
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    vm.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _buildFullWidthButton(
                            context,
                            AppStrings.get('login', lang),
                            () => vm.login(context),
                            isPrimary: true,
                          ),

                    Center(
                      child: TextButton(
                        onPressed: () => vm.resendVerificationEmail(context),
                        child: Text(
                          lang == 'ar'
                              ? "لم يصلك رابط التفعيل؟ أعد الإرسال"
                              : "Didn't get link? Resend",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "OR",
                            style: TextStyle(color: theme.hintColor),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 25),

                    _buildFullWidthButton(
                      context,
                      AppStrings.get('signup', lang),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpScreen(),
                        ),
                      ),
                      isPrimary: false,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLabel(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onIconTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: onIconTap,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildFullWidthButton(
    BuildContext context,
    String text,
    VoidCallback onPressed, {
    required bool isPrimary,
  }) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? theme.primaryColor : Colors.transparent,
          elevation: isPrimary ? 2 : 0,
          side: isPrimary
              ? BorderSide.none
              : BorderSide(color: theme.primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isPrimary ? Colors.white : theme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
