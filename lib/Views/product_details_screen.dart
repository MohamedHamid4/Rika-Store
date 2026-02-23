import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:rika_store/Helpers/app_strings.dart';
import 'package:rika_store/ViewModel/product_details_viewmodel.dart';
import 'package:rika_store/AppTheme/app_colors.dart';
import 'package:rika_store/Views/cart_screen.dart';
import 'package:rika_store/ViewModel/cart_viewmodel.dart';
import 'package:rika_store/ViewModel/settings_viewmodel.dart';
import 'package:rika_store/Model/product_model.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel? product;
  final String? categoryName;

  const ProductDetailsScreen({super.key, this.product, this.categoryName});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final ProductModel? currentProduct = widget.product ?? args?['product'];

      if (currentProduct != null) {
        // ✅ الحل الجذري للخطأ: الانتظار حتى انتهاء الـ Build الحالي
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Provider.of<ProductDetailsViewModel>(context, listen: false)
                .initializeProduct(currentProduct.sizes, currentProduct.colors);
          }
        });
      }
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final ProductModel currentProduct = widget.product ?? args?['product'];
    final String currentCategory = widget.categoryName ?? args?['categoryName'] ?? "General";
    final String lang = Provider.of<SettingsViewModel>(context).appLocale.languageCode;

    // منطق التصنيفات والعناوين
    bool isBag = currentCategory.toLowerCase().contains("bag");
    bool isElectronics = currentCategory.toLowerCase().contains("electronic") ||
        currentCategory.toLowerCase().contains("headphone") ||
        currentCategory.toLowerCase().contains("watch");
    bool isShoes = currentCategory.toLowerCase().contains("shoes") ||
        currentCategory.toLowerCase().contains("sneaker");
    bool isClothing = currentCategory.toLowerCase().contains("clothing") ||
        currentCategory.toLowerCase().contains("shirt");

    String getDescriptionTitle() {
      if (isElectronics) return lang == 'ar' ? "المواصفات التقنية" : "Technical Specs";
      if (isClothing || isShoes) return lang == 'ar' ? "تفاصيل المقاس والخامة" : "Material & Fit";
      if (isBag) return lang == 'ar' ? "السعة والتصميم" : "Capacity & Design";
      return AppStrings.get('description', lang);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildImageHeader(context, currentProduct),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.primaryNavy
                    : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
              ),
              padding: const EdgeInsets.all(25),
              child: SingleChildScrollView(
                child: Consumer<ProductDetailsViewModel>(
                  builder: (context, vm, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitlePrice(context, currentProduct),
                        const SizedBox(height: 15),
                        _buildRating(lang),

                        // عرض المقاسات ديناميكياً
                        if (vm.availableSizes.isNotEmpty) ...[
                          const SizedBox(height: 25),
                          _sectionTitle(context, AppStrings.get('size', lang)),
                          const SizedBox(height: 10),
                          _buildSizeSelector(vm),
                        ],

                        // عرض الألوان ديناميكياً (محفوظة للمستقبل)
                        if (vm.availableColorsHex.isNotEmpty) ...[
                          const SizedBox(height: 25),
                          _sectionTitle(context, AppStrings.get('color', lang)),
                          const SizedBox(height: 10),
                          _buildColorSelector(vm),
                        ],

                        const SizedBox(height: 25),
                        _sectionTitle(context, getDescriptionTitle()),
                        const SizedBox(height: 10),
                        Text(
                          currentProduct.description,
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white70
                                : Colors.grey,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomButton(context, currentProduct, lang),
    );
  }

  Widget _buildImageHeader(BuildContext context, ProductModel product) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.4,
      child: Stack(
        children: [
          Center(
            child: Hero(
              tag: product.id,
              child: product.image.startsWith('http')
                  ? Image.network(
                product.image,
                width: 250,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Shimmer.fromColors(
                    baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                    highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
                    child: Container(width: 250, height: 250, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                  );
                },
              )
                  : Image.asset(product.image, width: 250, fit: BoxFit.contain),
            ),
          ),
          Positioned(top: 50, left: 20, child: _unifiedBackButton(context)),
        ],
      ),
    );
  }

  Widget _buildTitlePrice(BuildContext context, ProductModel product) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.brand, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(product.name, style: const TextStyle(color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        Text("\$${product.price}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSizeSelector(ProductDetailsViewModel vm) {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: vm.availableSizes.length,
        itemBuilder: (context, index) {
          final isSelected = vm.selectedSizeIndex == index;
          return GestureDetector(
            onTap: () => vm.setSize(index),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              width: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.black : Colors.transparent,
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Center(
                child: Text(vm.availableSizes[index], style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildColorSelector(ProductDetailsViewModel vm) {
    return Row(
      children: List.generate(vm.availableColorsHex.length, (index) {
        final isSelected = vm.selectedColorIndex == index;
        final color = vm.hexToColor(vm.availableColorsHex[index]);
        return GestureDetector(
          onTap: () => vm.setColor(index),
          child: Container(
            margin: const EdgeInsets.only(right: 15),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
            ),
            child: CircleAvatar(radius: 12, backgroundColor: color),
          ),
        );
      }),
    );
  }

  Widget _buildRating(String lang) {
    return Row(
      children: [
        ...List.generate(5, (index) => const Icon(Icons.star, color: Colors.orange, size: 20)),
        const SizedBox(width: 5),
        Text("(20 ${AppStrings.get('reviews', lang)})", style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18));
  }

  Widget _unifiedBackButton(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        height: 45, width: 45,
        decoration: BoxDecoration(
            color: isDark ? AppColors.primaryNavy : Colors.white,
            shape: BoxShape.circle,
            boxShadow: isDark ? [] : [const BoxShadow(color: Colors.black12, blurRadius: 5)]),
        child: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppColors.primaryNavy, size: 20),
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context, ProductModel product, String lang) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Consumer<ProductDetailsViewModel>(
      builder: (context, vm, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          color: isDark ? AppColors.primaryNavy : Colors.white,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.luxuryGold : Theme.of(context).primaryColor,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: vm.isAddingToCart ? null : () async {
              vm.setAddingToCart(true);
              await Provider.of<CartViewModel>(context, listen: false).addToCart(product);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.get('added_to_cart', lang))));
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen(showBackButton: true)));
              }
              vm.setAddingToCart(false);
            },
            icon: vm.isAddingToCart ? const SizedBox.shrink() : const Icon(Icons.shopping_bag_outlined, color: Colors.white),
            label: vm.isAddingToCart ? const CircularProgressIndicator(color: Colors.white) : Text(AppStrings.get('add_to_cart', lang), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }
}