import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rika_store/Model/product_model.dart';

class BannerModel {
  final String imageUrl;

  BannerModel({required this.imageUrl});

  factory BannerModel.fromMap(Map<String, dynamic> map) {
    return BannerModel(
      imageUrl: map['image'] ?? map['imgurl'] ?? map['imageUrl'] ?? '',
    );
  }
}

class HomeViewModel extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<ProductModel> _allProducts = [];
  List<ProductModel> _newArrivals = [];
  List<ProductModel> _filteredProducts = [];
  List<BannerModel> _banners = [];

  bool _isLoading = false;
  bool _isSearching = false;

  List<ProductModel> get newArrivals => _newArrivals;
  List<ProductModel> get filteredProducts => _filteredProducts;
  List<BannerModel> get banners => _banners;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;

  Future<void> fetchAllProductsForSearch() async {
    try {
      QuerySnapshot snapshot = await _db.collection('products').get();
      _allProducts = snapshot.docs.map((doc) {
        return ProductModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();

      debugPrint("✅ تم جلب ${_allProducts.length} منتج للبحث الشامل");
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error Fetching All Products: $e");
    }
  }

  void searchProducts(String query) {
    final cleanQuery = query.trim().toLowerCase();

    if (cleanQuery.isEmpty) {
      _isSearching = false;
      _filteredProducts = [];
    } else {
      _isSearching = true;
      _filteredProducts = _allProducts.where((product) {
        final nameLower = product.name.toLowerCase();
        final brandLower = product.brand.toLowerCase();
        final categoryLower = (product.category ?? "").toLowerCase();

        return nameLower.contains(cleanQuery) ||
            brandLower.contains(cleanQuery) ||
            categoryLower.contains(cleanQuery);
      }).toList();
    }
    notifyListeners();
  }

  Future<void> fetchBanners() async {
    try {
      QuerySnapshot snapshot = await _db.collection('banners').get();
      _banners = snapshot.docs
          .map((doc) => BannerModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error Banners: $e");
    }
  }

  Future<void> fetchNewArrivals() async {
    _isLoading = true;
    notifyListeners();
    try {
      QuerySnapshot snapshot = await _db
          .collection('products')
          .where('isNew', isEqualTo: true)
          .limit(10)
          .get();

      _newArrivals = snapshot.docs
          .map(
            (doc) => ProductModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        ),
      )
          .toList();
    } catch (e) {
      debugPrint("❌ Error Products: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleFavorite(ProductModel product) async {
    product.isFavorite = !product.isFavorite;
    notifyListeners();

    try {
      await _db.collection('products').doc(product.id).set({
        'isFavorite': product.isFavorite,
      }, SetOptions(merge: true));
    } catch (e) {
      product.isFavorite = !product.isFavorite;
      notifyListeners();
      debugPrint("❌ Error Toggling Favorite: $e");
    }
  }
}