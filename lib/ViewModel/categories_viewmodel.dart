import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Model/categories_model.dart';
import '../Helpers/app_strings.dart';

class CategoriesViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<CategoriesModel> _categories = [];
  bool _isLoading = false;

  List<CategoriesModel> get categories => _categories;

  bool get isLoading => _isLoading;

  Future<void> fetchCategoriesFromFirebase(String lang) async {
    _isLoading = true;
    notifyListeners();

    try {
      QuerySnapshot categorySnapshot = await _firestore
          .collection('categories')
          .get();

      List<CategoriesModel> fetchedCategories = [];

      for (var doc in categorySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        String categoryName = data['name'] ?? '';
        String categoryId = doc.id;

        if (categoryName.toLowerCase().contains('new_arrivals') ||
            categoryName.toLowerCase().contains('new-arrivals')) {
          continue;
        }

        int productsCount = await _getProductsCount(categoryId, categoryName);

        fetchedCategories.add(
          CategoriesModel(
            id: categoryId,
            title: AppStrings.get(categoryName, lang),
            productCount: "$productsCount Product",
            image: data['imgurl'] ?? 'assets/images/clothes.png',
          ),
        );
      }

      _categories = fetchedCategories;
      debugPrint(
        "✅ Done: Fetched ${_categories.length} categories with dynamic counts",
      );
    } catch (e) {
      debugPrint("❌ Error fetching categories: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<int> _getProductsCount(String id, String name) async {
    try {
      Query query;
      if (id == 'perfumes_beauty' || name == 'Perfumes & Beauty') {
        query = _firestore
            .collection('products')
            .where('category', isEqualTo: 'Perfumes & Beauty');
      } else {
        query = _firestore
            .collection('products')
            .where('category_id', isEqualTo: id);
      }

      AggregateQuerySnapshot countSnapshot = await query.count().get();
      return countSnapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
