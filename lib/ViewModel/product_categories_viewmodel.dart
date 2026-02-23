import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Model/product_model.dart';

class ProductCategoriesViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<ProductModel> _allProducts = [];
  bool _isLoading = false;

  List<ProductModel> get allProducts => _allProducts;

  bool get isLoading => _isLoading;

  Future<void> fetchProductsFromFirebase(String selectedCategoryId) async {
    _isLoading = true;
    _allProducts = [];
    notifyListeners();

    try {
      Query query;

      if (selectedCategoryId == 'new_arrivals') {
        query = _firestore
            .collection('products')
            .where('isNew', isEqualTo: true);
      } else if (selectedCategoryId == 'perfumes_beauty') {
        query = _firestore
            .collection('products')
            .where('category', isEqualTo: 'Perfumes & Beauty');
      } else {
        query = _firestore
            .collection('products')
            .where('category_id', isEqualTo: selectedCategoryId.trim());
      }

      QuerySnapshot querySnapshot = await query.get();

      _allProducts = querySnapshot.docs.map((doc) {
        return ProductModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();

      debugPrint(
        "✅ Found ${_allProducts.length} products for $selectedCategoryId",
      );
    } catch (e) {
      debugPrint("❌ Firebase Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleFavorite(ProductModel product) async {
    product.isFavorite = !product.isFavorite;
    notifyListeners();

    try {
      await _firestore.collection('products').doc(product.id).set({
        'isFavorite': product.isFavorite,
      }, SetOptions(merge: true));

      debugPrint(
        "✅ Firebase Updated (Category): ${product.name} = ${product.isFavorite}",
      );
    } catch (e) {
      debugPrint("❌ Error updating favorite: $e");
      product.isFavorite = !product.isFavorite;
      notifyListeners();
    }
  }
}
