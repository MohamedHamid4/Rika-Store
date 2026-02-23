import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rika_store/Helpers/app_strings.dart';
import 'package:rika_store/ViewModel/signup_viewmodel.dart';
import 'package:rika_store/AppTheme/app_colors.dart';
import 'package:rika_store/ViewModel/settings_viewmodel.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final String lang = Provider.of<SettingsViewModel>(context).appLocale.languageCode;

    return ChangeNotifierProvider(
      create: (_) => SignUpViewModel(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new,
                color: theme.textTheme.displayLarge?.color, size: 22),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Consumer<SignUpViewModel>(
          builder: (context, vm, child) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Center(
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 120,
                        color: isDarkMode ? theme.colorScheme.secondary : null,
                        errorBuilder: (context, error, stackTrace) => Text(
                          "RIKA",
                          style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? theme.colorScheme.secondary
                                  : theme.primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(AppStrings.get('signup', lang),
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.displayLarge?.color)),
                    const SizedBox(height: 10),
                    Text(AppStrings.get('signup_subtitle', lang),
                        style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color,
                            fontSize: 14)),
                    const SizedBox(height: 40),

                    _buildTitle(AppStrings.get('name_label', lang), theme),
                    _buildTextField(
                      context: context,
                      controller: vm.nameController,
                      hint: "RIKA FASHION",
                      suffix: Icon(Icons.person_outline,
                          color: isDarkMode
                              ? theme.colorScheme.secondary
                              : Colors.black,
                          size: 20),
                    ),

                    const SizedBox(height: 25),
                    _buildTitle(AppStrings.get('email_label', lang), theme),
                    _buildTextField(
                      context: context,
                      controller: vm.emailController,
                      hint: "example@gmail.com",
                      suffix: Icon(Icons.email_outlined, size: 20,
                          color: isDarkMode ? theme.colorScheme.secondary : Colors.black),
                    ),

                    const SizedBox(height: 25),
                    _buildTitle(AppStrings.get('password', lang), theme),
                    _buildTextField(
                      context: context,
                      controller: vm.passwordController,
                      hint: "••••",
                      isObscure: vm.isPasswordHidden,
                      suffix: IconButton(
                        icon: Icon(
                          vm.isPasswordHidden
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: isDarkMode
                              ? theme.colorScheme.secondary
                              : Colors.black,
                          size: 20,
                        ),
                        onPressed: () => vm.togglePasswordVisibility(),
                      ),
                    ),

                    const SizedBox(height: 25),
                    _buildTitle(AppStrings.get('confirm_password', lang), theme),
                    _buildTextField(
                      context: context,
                      controller: vm.confirmPasswordController,
                      hint: "••••",
                      isObscure: vm.isConfirmHidden,
                      suffix: IconButton(
                        icon: Icon(
                          vm.isConfirmHidden
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: isDarkMode
                              ? theme.colorScheme.secondary
                              : Colors.black,
                          size: 20,
                        ),
                        onPressed: () => vm.toggleConfirmVisibility(),
                      ),
                    ),

                    const SizedBox(height: 50),

                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () => vm.signUp(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode
                              ? theme.colorScheme.secondary
                              : AppColors.primaryNavy,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(35)),
                        ),
                        child: Text(AppStrings.get('signup_button', lang),
                            style: TextStyle(
                                color: isDarkMode ? Colors.black : Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTitle(String title, ThemeData theme) {
    return Text(title,
        style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: theme.textTheme.displayLarge?.color));
  }

  Widget _buildTextField(
      {required BuildContext context,
        required TextEditingController controller,
        required String hint,
        bool isObscure = false,
        Widget? suffix}) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return TextField(
      controller: controller,
      obscureText: isObscure,
      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5)),
        suffixIcon: suffix,
        enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
                color: isDarkMode ? Colors.white24 : Colors.black12)),
        focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
                color: isDarkMode
                    ? theme.colorScheme.secondary
                    : AppColors.primaryNavy)),
      ),
    );
  }
}