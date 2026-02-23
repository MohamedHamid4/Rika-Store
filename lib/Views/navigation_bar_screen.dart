import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rika_store/AppTheme/app_colors.dart';
import 'package:rika_store/Helpers/app_strings.dart';
import 'package:rika_store/ViewModel/navigation_viewmodel.dart';
import 'package:rika_store/Views/home_screen.dart';
import 'package:rika_store/Views/cart_screen.dart';
import 'package:rika_store/Views/notification_screen.dart';
import 'package:rika_store/Views/profile_screen.dart';
import 'package:rika_store/ViewModel/settings_viewmodel.dart';

class NavigationBarScreen extends StatelessWidget {
  const NavigationBarScreen({super.key});

  static const List<Widget> _pages = [
    HomeScreen(),
    CartScreen(showBackButton: false),
    NotificationScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final navVM = Provider.of<NavigationViewModel>(context);

    final String lang = Provider.of<SettingsViewModel>(context).appLocale.languageCode;

    return WillPopScope(
      onWillPop: () async {
        if (navVM.selectedIndex != 0) {
          navVM.setIndex(0);
          return false;
        }
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        body: IndexedStack(
          index: navVM.selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: Container(
          height: 85,
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.primaryNavy : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, 'assets/images/home.png', AppStrings.get('home', lang), context, navVM),
              _buildNavItem(1, 'assets/images/cart.png', AppStrings.get('cart', lang), context, navVM),
              _buildNavItem(2, 'assets/images/alert.png', AppStrings.get('notifications', lang), context, navVM),
              _buildNavItem(3, 'assets/images/profile.png', AppStrings.get('profile', lang), context, navVM),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String imagePath, String label,
      BuildContext context, NavigationViewModel navVM) {
    final bool isSelected = navVM.selectedIndex == index;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => navVM.setIndex(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.shade100)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryNavy : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                imagePath,
                width: 22,
                height: 22,
                color: isSelected
                    ? Colors.white
                    : (isDarkMode ? Colors.white54 : Colors.grey),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDarkMode ? Colors.white : AppColors.primaryNavy,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}