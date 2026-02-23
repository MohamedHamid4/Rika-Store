import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Model/product_model.dart';

class FavoritesViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<ProductModel> _favoriteProducts = [];
  bool _isLoading = false;

  List<ProductModel> get favoriteProducts => _favoriteProducts;

  bool get isLoading => _isLoading;

  Future<void> fetchFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      QuerySnapshot allDocs = await _firestore.collection('products').get();

      for (var doc in allDocs.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        debugPrint(
          "🔍 Product: ${data['name']} | isFavorite: ${data['isFavorite']}",
        );
      }

      QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('isFavorite', isEqualTo: true)
          .get();

      _favoriteProducts = snapshot.docs.map((doc) {
        return ProductModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();

      debugPrint("✅ Favorites count: ${_favoriteProducts.length}");
    } catch (e) {
      debugPrint("❌ Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
