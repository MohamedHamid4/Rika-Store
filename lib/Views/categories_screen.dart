import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:rika_store/Helpers/app_strings.dart';
import 'package:rika_store/Model/categories_model.dart';
import 'package:rika_store/ViewModel/categories_viewmodel.dart';
import 'package:rika_store/AppTheme/app_colors.dart';
import 'package:rika_store/ViewModel/settings_viewmodel.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String lang = Provider.of<SettingsViewModel>(
        context,
        listen: false,
      ).appLocale.languageCode;
      Provider.of<CategoriesViewModel>(
        context,
        listen: false,
      ).fetchCategoriesFromFirebase(lang);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CategoriesViewModel>(context);
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final String lang = Provider.of<SettingsViewModel>(
      context,
    ).appLocale.languageCode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 70,
        leading: _buildUnifiedBackButton(context),
        title: Text(
          AppStrings.get('categories', lang),
          style: TextStyle(
            color: isDarkMode ? Colors.white : AppColors.primaryNavy,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
      ),
      // التبديل بين الشيمر والبيانات الحقيقية
      body: vm.isLoading
          ? _buildShimmerGrid(isDarkMode)
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 18,
                mainAxisSpacing: 22,
                childAspectRatio: 0.75,
              ),
              itemCount: vm.categories.length,
              itemBuilder: (context, index) {
                return _buildEnhancedCategoryCard(
                  context,
                  vm.categories[index],
                );
              },
            ),
    );
  }

  // دالة بناء شبكة الشيمر
  Widget _buildShimmerGrid(bool isDarkMode) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 18,
        mainAxisSpacing: 22,
        childAspectRatio: 0.75,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
          highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUnifiedBackButton(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.primaryNavy : Colors.white,
          shape: BoxShape.circle,
          boxShadow: !isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Icon(
          Icons.arrow_back,
          color: isDark ? Colors.white : AppColors.primaryNavy,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildEnhancedCategoryCard(
    BuildContext context,
    CategoriesModel item,
  ) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/product_categories',
          arguments: {'id': item.id, 'title': item.title},
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.4 : 0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned.fill(
                child: item.image.startsWith('http')
                    ? Image.network(
                        item.image,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Shimmer.fromColors(
                            baseColor: isDarkMode
                                ? Colors.grey[800]!
                                : Colors.grey[300]!,
                            highlightColor: isDarkMode
                                ? Colors.grey[700]!
                                : Colors.grey[100]!,
                            child: Container(color: Colors.white),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                              child: Icon(Icons.broken_image, size: 40),
                            ),
                      )
                    : Image.asset(item.image, fit: BoxFit.cover),
              ),
              Positioned(
                bottom: 15,
                left: 10,
                right: 10,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? AppColors.primaryNavy.withValues(alpha: 0.7)
                            : Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.white
                                  : AppColors.primaryNavy,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.productCount,
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.grey.shade700,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
