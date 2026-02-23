import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart'; // سطر مضاف لربط الفايربيز
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rika_store/AppTheme/app_colors.dart';
import 'package:rika_store/Helpers/app_strings.dart';
import 'package:rika_store/ViewModel/personal_details_viewmodel.dart';
import 'package:rika_store/Views/personal_details_screen.dart';
import 'package:rika_store/Views/settings_screen.dart';
import 'package:rika_store/ViewModel/settings_viewmodel.dart';

import 'favorites_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final personalVM = Provider.of<PersonalDetailsViewModel>(context);
    final String lang = Provider.of<SettingsViewModel>(
      context,
    ).appLocale.languageCode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            _buildUserHeader(isDarkMode, personalVM, theme),
            const SizedBox(height: 25),

            _buildOptionsGroup(context, isDarkMode, theme, [
              _OptionItem(
                Icons.person_outline,
                AppStrings.get('personal_details', lang),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PersonalDetailsScreen(),
                    ),
                  );
                },
              ),
              _OptionItem(
                Icons.shopping_bag_outlined,
                AppStrings.get('my_orders', lang),
              ),
              _OptionItem(
                Icons.favorite_border,
                AppStrings.get('my_favourites', lang),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FavoritesScreen(),
                    ),
                  );
                },
              ),
              _OptionItem(
                Icons.local_shipping_outlined,
                AppStrings.get('shipping_address', lang),
              ),
              _OptionItem(
                Icons.credit_card_outlined,
                AppStrings.get('my_cards', lang),
              ),
              _OptionItem(
                Icons.settings_outlined,
                AppStrings.get('settings', lang),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
            ]),
            const SizedBox(height: 20),

            _buildOptionsGroup(context, isDarkMode, theme, [
              _OptionItem(Icons.help_outline, AppStrings.get('faqs', lang)),
              _OptionItem(
                Icons.security_outlined,
                AppStrings.get('privacy_policy', lang),
              ),
              _OptionItem(
                Icons.groups_outlined,
                AppStrings.get('community', lang),
              ),
            ]),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(
    bool isDark,
    PersonalDetailsViewModel vm,
    ThemeData theme,
  ) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha:0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: vm.imagePath.isNotEmpty
                ? Image.file(
                    File(vm.imagePath),
                    width: 65,
                    height: 65,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/images/user-male.png',
                      width: 65,
                      height: 65,
                    ),
                  )
                : Image.asset(
                    'assets/images/user-male.png',
                    width: 65,
                    height: 65,
                  ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  currentUser?.displayName ?? vm.userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.primaryNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentUser?.email ?? vm.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsGroup(
    BuildContext context,
    bool isDark,
    ThemeData theme,
    List<_OptionItem> options,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: isDark ? Colors.transparent : theme.dividerColor,
        ),
      ),
      child: Column(
        children: options
            .map((opt) => _buildSingleTile(context, isDark, theme, opt))
            .toList(),
      ),
    );
  }

  Widget _buildSingleTile(
    BuildContext context,
    bool isDark,
    ThemeData theme,
    _OptionItem item,
  ) {
    return ListTile(
      onTap: item.onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.primaryColor.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(item.icon, size: 20, color: theme.primaryColor),
      ),
      title: Text(
        item.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: theme.iconTheme.color?.withValues(alpha:0.5),
      ),
    );
  }
}

class _OptionItem {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  _OptionItem(this.icon, this.title, {this.onTap});
}
