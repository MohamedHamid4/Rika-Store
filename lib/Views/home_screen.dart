import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rika_store/Helpers/app_strings.dart';
import 'package:rika_store/ViewModel/home_viewmodel.dart';
import 'package:rika_store/Views/categories_screen.dart';
import 'package:rika_store/Helpers/product_shimmer.dart';
import 'package:rika_store/ViewModel/settings_viewmodel.dart';
import 'package:rika_store/Model/product_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeVM = Provider.of<HomeViewModel>(context, listen: false);
      homeVM.fetchNewArrivals();
      homeVM.fetchBanners();
      homeVM.fetchAllProductsForSearch();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String lang = Provider.of<SettingsViewModel>(
      context,
    ).appLocale.languageCode;
    final homeVM = Provider.of<HomeViewModel>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await homeVM.fetchNewArrivals();
            await homeVM.fetchBanners();
            await homeVM.fetchAllProductsForSearch();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 35),
                _buildWelcomeText(theme, lang),
                const SizedBox(height: 25),
                _buildSearchAndCategoryRow(
                  theme,
                  theme.colorScheme.surface,
                  theme.colorScheme.primary,
                  lang,
                ),
                const SizedBox(height: 30),

                if (homeVM.isSearching) ...[
                  Text(
                    "${AppStrings.get('search_results', lang)} (${homeVM.filteredProducts.length})",
                    style: theme.textTheme.displayLarge?.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 15),
                  _buildProductsSection(homeVM, homeVM.filteredProducts),
                ] else ...[
                  _buildBannerSlider(),
                  const SizedBox(height: 30),
                  _buildSectionHeader(
                    theme,
                    AppStrings.get('new_arrivals', lang),
                    lang,
                    onViewAllTap: () => Navigator.pushNamed(
                      context,
                      '/product_categories',
                      arguments: 'new_arrivals',
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildProductsSection(homeVM, homeVM.newArrivals),
                ],
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductsSection(
    HomeViewModel homeVM,
    List<ProductModel> listToDisplay,
  ) {
    if (homeVM.isLoading && !homeVM.isSearching) return _buildShimmerRow();

    if (listToDisplay.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text("لا توجد منتجات مطابقة لبحثك"),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: homeVM.isSearching
          ? listToDisplay.length
          : (listToDisplay.length > 2 ? 2 : listToDisplay.length),
      itemBuilder: (context, index) {
        return _buildProductCard(context, listToDisplay[index], homeVM);
      },
    );
  }

  Widget _buildSearchBar(ThemeData theme, Color surfaceColor, String lang) {
    final homeVM = Provider.of<HomeViewModel>(context, listen: false);
    return TextField(
      controller: _searchController,
      onChanged: (value) => homeVM.searchProducts(value),
      decoration: InputDecoration(
        hintText: AppStrings.get('search', lang),
        prefixIcon: Icon(
          Icons.search,
          color: theme.colorScheme.primary.withValues(alpha: 0.5),
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  homeVM.searchProducts("");
                },
              )
            : null,
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 20,
        ),
      ),
    );
  }

  Widget _buildWelcomeText(ThemeData theme, String lang) {
    final user = FirebaseAuth.instance.currentUser;
    String firstName = (user?.displayName?.split(' ').first) ?? "";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppStrings.get('Welcome', lang),
              style: theme.textTheme.displayLarge?.copyWith(fontSize: 28),
            ),
            if (firstName.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(
                "$firstName!",
                style: theme.textTheme.displayLarge?.copyWith(
                  fontSize: 28,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ],
        ),
        Text(
          AppStrings.get('Rika Store', lang),
          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildSearchAndCategoryRow(
    ThemeData theme,
    Color surfaceColor,
    Color primaryColor,
    String lang,
  ) {
    return Row(
      children: [
        Expanded(child: _buildSearchBar(theme, surfaceColor, lang)),
        const SizedBox(width: 15),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CategoriesScreen()),
          ),
          child: _buildCategoryIcon(primaryColor),
        ),
      ],
    );
  }

  Widget _buildCategoryIcon(Color iconColor) => Container(
    width: 50,
    height: 50,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      shape: BoxShape.circle,
    ),
    padding: const EdgeInsets.all(13),
    child: Image.asset('assets/images/categories.png', color: iconColor),
  );

  Widget _buildProductCard(
    BuildContext context,
    ProductModel product,
    HomeViewModel homeVM,
  ) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/product_details',
        arguments: {'product': product, 'categoryName': product.category},
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child:
                      (product.image.isEmpty ||
                          !product.image.startsWith('http'))
                      ? const Icon(Icons.broken_image, size: 80)
                      : Image.network(
                          product.image,
                          height: 120,
                          fit: BoxFit.contain,
                          errorBuilder: (c, e, s) =>
                              const Icon(Icons.broken_image, size: 50),
                        ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => homeVM.toggleFavorite(product),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? Colors.black54
                          : Colors.white70,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      product.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: product.isFavorite
                          ? Colors.red
                          : (theme.brightness == Brightness.dark
                                ? Colors.white
                                : Colors.grey),
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            product.brand,
            style: theme.textTheme.displayLarge?.copyWith(fontSize: 14),
          ),
          Text(
            product.name,
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            "\$${product.price}",
            style: theme.textTheme.displayLarge?.copyWith(fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerSlider() {
    return Consumer<HomeViewModel>(
      builder: (context, homeVM, child) {
        if (homeVM.banners.isEmpty) {
          return const SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return SizedBox(
          height: 160,
          child: PageView.builder(
            itemCount: homeVM.banners.length,
            controller: PageController(viewportFraction: 0.9),
            itemBuilder: (context, index) => Container(
              margin: const EdgeInsets.only(right: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.network(
                  homeVM.banners[index].imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(
    ThemeData theme,
    String title,
    String lang, {
    required VoidCallback onViewAllTap,
  }) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: theme.textTheme.displayLarge?.copyWith(fontSize: 20)),
      TextButton(
        onPressed: onViewAllTap,
        child: Text(
          AppStrings.get('view_all', lang),
          style: TextStyle(color: theme.colorScheme.secondary),
        ),
      ),
    ],
  );

  Widget _buildShimmerRow() => const Row(
    children: [
      Expanded(child: ProductShimmer()),
      SizedBox(width: 15),
      Expanded(child: ProductShimmer()),
    ],
  );
}
