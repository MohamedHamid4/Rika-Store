import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rika_store/AppTheme/app_colors.dart';
import 'package:rika_store/Helpers/app_strings.dart';
import 'package:rika_store/ViewModel/settings_viewmodel.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsVM = Provider.of<SettingsViewModel>(context);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDarkModeNow = settingsVM.isDarkMode;

    final String lang = settingsVM.appLocale.languageCode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDarkModeNow ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppStrings.get('settings', lang),
          style: theme.textTheme.displayLarge?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkModeNow ? Colors.white : Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDarkModeNow ? 0.4 : 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                children: [
                  _buildSettingTile(
                    context,
                    Icons.language,
                    AppStrings.get('language', lang),
                    trailing: Text(settingsVM.selectedLanguage,
                        style: TextStyle(
                            color: isDarkModeNow
                                ? Colors.white70
                                : Colors.black54)),
                    onTap: () => _showLanguageBottomSheet(context, settingsVM),
                  ),
                  _buildSettingTile(
                    context,
                    Icons.notifications_none,
                    AppStrings.get('notifications', lang),
                    trailing: Switch(
                      value: settingsVM.notificationsEnabled,
                      onChanged: (val) => settingsVM.toggleNotifications(val),
                      activeColor: colorScheme.primary,
                    ),
                  ),
                  _buildSettingTile(
                    context,
                    Icons.dark_mode_outlined,
                    AppStrings.get('theme_mode', lang),
                    trailing: Text(
                      isDarkModeNow ? "Dark Mode" : "Light Mode",
                      style: TextStyle(
                          color:
                              isDarkModeNow ? Colors.white70 : Colors.black54),
                    ),
                    onTap: () => _showThemeBottomSheet(
                        context, settingsVM),
                  ),
                  _buildSettingTile(
                      context, Icons.help_outline, AppStrings.get('help', lang),
                      showArrow: true),
                ],
              ),
            ),
            const Spacer(),
            _buildLogoutButton(context, settingsVM, lang),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showThemeBottomSheet(BuildContext context, SettingsViewModel vm) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDark = vm.isDarkMode;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 15),
          ListTile(
            leading: Icon(Icons.light_mode,
                color: !isDark ? colorScheme.primary : Colors.grey),
            title: Text("Light Mode",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        !isDark ? colorScheme.primary : colorScheme.onSurface)),
            trailing: !isDark
                ? Icon(Icons.check_circle, color: colorScheme.primary)
                : null,
            onTap: () {
              vm.toggleTheme(false);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.dark_mode,
                color: isDark ? colorScheme.primary : Colors.grey),
            title: Text("Dark Mode",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        isDark ? colorScheme.primary : colorScheme.onSurface)),
            trailing: isDark
                ? Icon(Icons.check_circle, color: colorScheme.primary)
                : null,
            onTap: () {
              vm.toggleTheme(true);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context, SettingsViewModel vm) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 15),
          ListTile(
            title: Text("English",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
            trailing: vm.appLocale.languageCode == 'en'
                ? Icon(Icons.check_circle, color: colorScheme.primary)
                : null,
            onTap: () {
              vm.changeLanguage('en');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text("العربية",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
            trailing: vm.appLocale.languageCode == 'ar'
                ? Icon(Icons.check_circle, color: colorScheme.primary)
                : null,
            onTap: () {
              vm.changeLanguage('ar');
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSettingTile(BuildContext context, IconData icon, String title,
      {Widget? trailing, bool showArrow = false, VoidCallback? onTap}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 22, color: theme.primaryColor),
      ),
      title: Text(title,
          style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.w500)),
      trailing: trailing ??
          (showArrow
              ? Icon(Icons.arrow_forward_ios,
                  size: 14, color: isDark ? Colors.white30 : Colors.black26)
              : null),
    );
  }

  Widget _buildLogoutButton(
      BuildContext context, SettingsViewModel vm, String lang) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ElevatedButton(
      onPressed: () async {
        await vm.logout();
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
              context, '/login', (route) => false);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isDark ? theme.colorScheme.secondary : AppColors.primaryNavy,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.logout, color: isDark ? Colors.black : Colors.white),
          const SizedBox(width: 10),
          Text(AppStrings.get('logout', lang),
              style: TextStyle(
                  color: isDark ? Colors.black : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
