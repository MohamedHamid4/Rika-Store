import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rika_store/AppTheme/app_colors.dart';
import 'package:rika_store/Helpers/app_strings.dart';
import 'package:rika_store/ViewModel/settings_viewmodel.dart';
import 'package:rika_store/Views/navigation_bar_screen.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final String lang = Provider.of<SettingsViewModel>(
      context,
    ).appLocale.languageCode;

    final Color primaryAccent = isDarkMode
        ? AppColors.luxuryGold
        : AppColors.primaryNavy;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDarkMode
                    ? [Colors.black, theme.scaffoldBackgroundColor]
                    : [Colors.grey.shade50, Colors.white],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 800),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double value, child) {
                      return Transform.scale(scale: value, child: child);
                    },
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: primaryAccent.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: primaryAccent.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.check_circle_rounded,
                          size: 100,
                          color: primaryAccent,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  Text(
                    AppStrings.get('successful_login!', lang),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: isDarkMode ? Colors.white : AppColors.primaryNavy,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    AppStrings.get(
                      'You_have_successfully_registered_in\n_our_app_and_start_working_in_it.',
                      lang,
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NavigationBarScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryAccent,
                        foregroundColor: isDarkMode
                            ? Colors.black
                            : Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        AppStrings.get('start_shopping', lang).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
