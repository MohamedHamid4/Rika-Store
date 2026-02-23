import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rika_store/AppTheme/app_colors.dart';
import 'package:rika_store/Helpers/preference_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _handleRouting();
      }
    });
  }

  void _handleRouting() {
    bool isFirstTime = PreferenceHelper.isFirstTime();

    User? user = FirebaseAuth.instance.currentUser;

    if (isFirstTime) {
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else if (user != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/splash.png',
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),
          Container(
            color: isDarkMode
                ? AppColors.primaryNavy.withValues(alpha: 0.6)
                : Colors.black.withValues(alpha: 0.15),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Hero(
                  tag: 'app_logo',
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 200,
                    height: 200,
                    filterQuality: FilterQuality.high,
                    color: isDarkMode ? AppColors.luxuryGold : null,
                    colorBlendMode: isDarkMode ? BlendMode.srcIn : null,
                  ),
                ),
                const SizedBox(height: 20),
                const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.luxuryGold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
