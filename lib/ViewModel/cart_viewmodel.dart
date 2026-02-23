import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Model/cart_model.dart';

class CartViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<CartModel> _items = [];
  bool _isLoading = false;

  List<CartModel> get items => _items;

  bool get isLoading => _isLoading;

  String get userId => _auth.currentUser?.uid ?? "";

  void fetchCartItems() {
    if (userId.isEmpty) return;

    _isLoading = true;

    _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .snapshots()
        .listen((snapshot) {
          _items = snapshot.docs.map((doc) {
            final data = doc.data();
            return CartModel(
              id: doc.id,
              brand: data['name'] ?? '',
              description: data['description'] ?? '',
              image: data['image'] ?? '',
              price: (data['price'] ?? 0).toDouble(),
              quantity: data['quantity'] ?? 1,
            );
          }).toList();

          _isLoading = false;
          notifyListeners();
        });
  }

  Future<void> addToCart(dynamic product) async {
    if (userId.isEmpty) return;

    final cartRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(product.id);

    final doc = await cartRef.get();

    if (doc.exists) {
      await cartRef.update({'quantity': FieldValue.increment(1)});
    } else {
      await cartRef.set({
        'name': product.name,
        'description': product.name,
        'image': product.image,
        'price': product.price,
        'quantity': 1,
        'addedAt': Timestamp.now(),
      });
    }
  }

  Future<void> updateQuantity(String itemId, bool isAdd) async {
    if (userId.isEmpty) return;

    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(itemId);

    if (isAdd) {
      await docRef.update({'quantity': FieldValue.increment(1)});
    } else {
      final doc = await docRef.get();
      if (doc.exists && doc['quantity'] > 1) {
        await docRef.update({'quantity': FieldValue.increment(-1)});
      } else {
        await removeItem(itemId);
      }
    }
  }

  Future<void> removeItem(String itemId) async {
    if (userId.isEmpty) return;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(itemId)
        .delete();
  }

  Future<void> clearCart() async {
    if (userId.isEmpty) return;

    try {
      var collection = _firestore
          .collection('users')
          .doc(userId)
          .collection('cart');

      var snapshots = await collection.get();

      WriteBatch batch = _firestore.batch();
      for (var doc in snapshots.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      _items = [];
      notifyListeners();
      debugPrint("✅ Cart cleared successfully after payment.");
    } catch (e) {
      debugPrint("❌ Error clearing cart: $e");
    }
  }

  double get totalPayment =>
      _items.fold(0, (sum, item) => sum + (item.price * item.quantity));
}
