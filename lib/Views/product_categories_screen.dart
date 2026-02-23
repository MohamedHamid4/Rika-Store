import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../Helpers/app_strings.dart';
import '../ViewModel/product_categories_viewmodel.dart';
import '../ViewModel/settings_viewmodel.dart';

class ProductCategoriesScreen extends StatefulWidget {
  const ProductCategoriesScreen({super.key});

  @override
  State<ProductCategoriesScreen> createState() =>
      _ProductCategoriesScreenState();
}

class _ProductCategoriesScreenState extends State<ProductCategoriesScreen> {
  bool _isInit = true;
  String? categoryId;
  String? categoryTitle;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final args = ModalRoute.of(context)?.settings.arguments;

      if (args != null) {
        if (args is String) {
          categoryId = args;
          categoryTitle = args;
        } else if (args is Map<String, dynamic>) {
          categoryId = args['id'];
          categoryTitle = args['title'];
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && categoryId != null) {
            Provider.of<ProductCategoriesViewModel>(
              context,
              listen: false,
            ).fetchProductsFromFirebase(categoryId!);
          }
        });
      }
      _isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ProductCategoriesViewModel>(context);
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final String lang = Provider.of<SettingsViewModel>(
      context,
    ).appLocale.languageCode;

    String displayTitle;
    String cleanId = categoryId?.trim().toLowerCase() ?? "";

    if (cleanId == 'perfumes_beauty' ||
        cleanId == 'perfumes-beauty' ||
        cleanId.contains('perfumes')) {
      displayTitle = "Perfumes and Beauty";
    } else if (cleanId == 'new_arrivals' || cleanId == 'new-arrivals') {
      displayTitle = AppStrings.get('new_arrivals', lang);
    } else {
      displayTitle = AppStrings.get(
        categoryTitle ?? '',
        lang,
      ).replaceAll('-', ' ');
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              displayTitle,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: vm.isLoading
                ? _buildShimmerLoading(isDarkMode)
                : vm.allProducts.isEmpty
                ? const Center(child: Text("No Products Found"))
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.62,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 25,
                        ),
                    itemCount: vm.allProducts.length,
                    itemBuilder: (context, index) {
                      final product = vm.allProducts[index];
                      return _buildProductCard(
                        context,
                        product,
                        vm,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading(bool isDarkMode) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 15,
        mainAxisSpacing: 25,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
          highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 100,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 60,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    dynamic product,
    ProductCategoriesViewModel vm,
  ) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/product_details',
          arguments: {'product': product, 'categoryName': product.category},
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child:
                        (product.image.isNotEmpty &&
                            product.image.startsWith('http'))
                        ? Image.network(
                            product.image,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) =>
                                const Icon(Icons.broken_image, size: 40),
                          )
                        : const Icon(Icons.image_not_supported, size: 40),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () {
                      vm.toggleFavorite(product);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.black54 : Colors.white70,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        (product.isFavorite ?? false)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: (product.isFavorite ?? false)
                            ? Colors.red
                            : (isDarkMode ? Colors.white : Colors.grey),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            "\$${product.price.toStringAsFixed(2)}",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
