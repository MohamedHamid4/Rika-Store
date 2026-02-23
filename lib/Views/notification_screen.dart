import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rika_store/AppTheme/app_colors.dart';
import 'package:rika_store/Helpers/app_strings.dart';
import 'package:rika_store/Model/notification_model.dart';
import 'package:rika_store/ViewModel/navigation_viewmodel.dart';
import 'package:rika_store/ViewModel/notification_viewmodel.dart';
import 'package:rika_store/ViewModel/settings_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late String userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid ?? "";

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userId.isNotEmpty) {
        Provider.of<NotificationViewModel>(
          context,
          listen: false,
        ).listenToNotifications(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vm = Provider.of<NotificationViewModel>(context);
    final navVM = Provider.of<NavigationViewModel>(context);
    final String lang = Provider.of<SettingsViewModel>(
      context,
    ).appLocale.languageCode;

    final List<NotificationModel> notificationsList = vm.notifications;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppStrings.get('notifications', lang),
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.primaryNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: navVM.selectedIndex == 2
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
        actions: const [],
      ),
      body: notificationsList.isEmpty
          ? _buildEmptyState(isDark, lang)
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: notificationsList.length,
              itemBuilder: (context, index) {
                final item = notificationsList[index];

                return _buildNotificationItem(item, isDark, lang, () {
                  vm.markAsRead(userId, item.id);
                });
              },
            ),
    );
  }

  Widget _buildNotificationItem(
    NotificationModel item,
    bool isDark,
    String lang,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.primaryNavy.withValues(alpha: 0.3)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: AppColors.primaryNavy.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
          ],
          border: item.isRead
              ? null
              : Border.all(color: AppColors.primaryNavy.withValues(alpha: 0.1)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTypeIcon(item.type, isDark),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isDark ? Colors.white : AppColors.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.message,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.grey.shade600,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getFormattedTime(item.timestamp, lang),
                    style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.grey.shade400,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (!item.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getFormattedTime(DateTime time, String lang) {
    try {
      return DateFormat.yMMMd(lang).add_jm().format(time);
    } catch (e) {
      return AppStrings.get('just_now', lang);
    }
  }

  Widget _buildTypeIcon(String type, bool isDark) {
    IconData icon;
    Color iconColor;
    if (type == 'offer') {
      icon = Icons.local_offer_outlined;
      iconColor = Colors.orange;
    } else {
      icon = Icons.shopping_bag_outlined;
      iconColor = isDark ? Colors.blueAccent : AppColors.primaryNavy;
    }
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: iconColor, size: 22),
    );
  }

  Widget _buildEmptyState(bool isDark, String lang) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 80,
            color: isDark
                ? Colors.white10
                : AppColors.primaryNavy.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 15),
          Text(
            AppStrings.get('no_notifications', lang),
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
