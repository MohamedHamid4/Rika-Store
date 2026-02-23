import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:rika_store/AppTheme/app_colors.dart';
import 'package:rika_store/Helpers/app_strings.dart';
import 'package:rika_store/ViewModel/cart_viewmodel.dart';
import 'package:rika_store/ViewModel/settings_viewmodel.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  final bool showBackButton;

  const CartScreen({super.key, this.showBackButton = false});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartViewModel>(context, listen: false).fetchCartItems();
    });
  }

  @override
  Widget build(BuildContext context) {
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
        automaticallyImplyLeading: false,
        leading: widget.showBackButton
            ? _buildUnifiedBackButton(context)
            : null,
        title: Text(
          AppStrings.get('cart', lang),
          style: TextStyle(
            color: isDarkMode ? Colors.white : AppColors.primaryNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [_buildCartBadge(context), const SizedBox(width: 15)],
      ),
      body: Consumer<CartViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return _buildShimmerList(isDarkMode);
          }

          if (vm.items.isEmpty) {
            return Center(
              child: Text(
                AppStrings.get('empty_cart', lang),
                style: const TextStyle(fontSize: 18),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  itemCount: vm.items.length,
                  itemBuilder: (context, index) =>
                      _buildDismissibleItem(context, vm, index, lang),
                ),
              ),
              _buildPromoCodeSection(context, lang),
              _buildSummarySection(context, vm, lang),
            ],
          );
        },
      ),
    );
  }

  Widget _buildShimmerList(bool isDarkMode) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: 5, // عرض 5 عناصر وهمية
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
          highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(12),
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDismissibleItem(
    BuildContext context,
    CartViewModel vm,
    int index,
    String lang,
  ) {
    final item = vm.items[index];
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => vm.removeItem(item.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete, color: Colors.red),
      ),
      child: _buildCartItem(context, vm, index),
    );
  }

  Widget _buildCartItem(BuildContext context, CartViewModel vm, int index) {
    final item = vm.items[index];
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                ),
              ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Container(
              width: 80,
              height: 80,
              color: isDark ? Colors.white10 : Colors.grey.shade100,
              child: item.image.startsWith('http')
                  ? Image.network(
                      item.image,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Shimmer.fromColors(
                          baseColor: isDark
                              ? Colors.grey[800]!
                              : Colors.grey[300]!,
                          highlightColor: isDark
                              ? Colors.grey[700]!
                              : Colors.grey[100]!,
                          child: Container(color: Colors.white),
                        );
                      },
                      errorBuilder: (c, e, s) => const Icon(Icons.broken_image),
                    )
                  : Image.asset(
                      item.image,
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) =>
                          const Icon(Icons.image_not_supported),
                    ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.brand,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item.description,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  maxLines: 1,
                ),
                const SizedBox(height: 5),
                Text(
                  "\$${item.price.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: AppColors.luxuryGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _qtyCounter(context, vm, index),
        ],
      ),
    );
  }

  Widget _buildSummarySection(
    BuildContext context,
    CartViewModel vm,
    String lang,
  ) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: isDark ? AppColors.primaryNavy : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.get('Total Payment', lang),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "\$${vm.totalPayment.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.luxuryGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark
                  ? AppColors.luxuryGold
                  : Theme.of(context).primaryColor,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CheckoutScreen()),
              );
            },
            child: Text(
              AppStrings.get('Checkout', lang),
              style: TextStyle(
                color: isDark ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnifiedBackButton(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.primaryNavy : Colors.white,
          shape: BoxShape.circle,
          boxShadow: isDark
              ? []
              : [const BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: Icon(
          Icons.arrow_back,
          color: isDark ? Colors.white : AppColors.primaryNavy,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildPromoCodeSection(BuildContext context, String lang) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.local_offer_outlined,
              color: AppColors.luxuryGold,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: AppStrings.get('Promo', lang),
                  border: InputBorder.none,
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                AppStrings.get('apply', lang),
                style: const TextStyle(
                  color: AppColors.luxuryGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartBadge(BuildContext context) {
    return Consumer<CartViewModel>(
      builder: (context, vm, child) {
        return Stack(
          alignment: Alignment.topRight,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.shopping_bag_outlined,
                color: AppColors.luxuryGold,
                size: 28,
              ),
            ),
            if (vm.items.isNotEmpty)
              CircleAvatar(
                radius: 9,
                backgroundColor: Colors.red,
                child: Text(
                  "${vm.items.length}",
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _qtyCounter(BuildContext context, CartViewModel vm, int index) {
    final item = vm.items[index];
    return Row(
      children: [
        _qtyBtn(Icons.remove, () => vm.updateQuantity(item.id, false)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            "${item.quantity}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        _qtyBtn(Icons.add, () => vm.updateQuantity(item.id, true)),
      ],
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}
