import 'package:flutter/material.dart';

class ProductDetailsViewModel extends ChangeNotifier {
  int selectedSizeIndex = 0;
  int selectedColorIndex = 0;
  int quantity = 1;
  bool isFavorite = false;
  bool isAddingToCart = false;

  List<String> availableSizes = [];
  List<String> availableColorsHex = [];

  void initializeProduct(List<String>? sizes, List<String>? colors) {
    availableSizes = sizes ?? [];
    availableColorsHex = colors ?? [];
    selectedSizeIndex = 0;
    selectedColorIndex = 0;
    quantity = 1;
    notifyListeners(); // تنبيه الواجهة بوجود بيانات جديدة
  }

  void toggleFavorite() {
    isFavorite = !isFavorite;
    notifyListeners();
  }

  void setSize(int index) {
    selectedSizeIndex = index;
    notifyListeners();
  }

  void setColor(int index) {
    selectedColorIndex = index;
    notifyListeners();
  }

  void updateQuantity(bool isAdd) {
    if (isAdd)
      quantity++;
    else if (quantity > 1)
      quantity--;
    notifyListeners();
  }

  void setAddingToCart(bool value) {
    isAddingToCart = value;
    notifyListeners();
  }

  Color hexToColor(String hexCode) {
    try {
      return Color(int.parse(hexCode.replaceFirst('#', '0xff')));
    } catch (e) {
      return Colors.grey;
    }
  }
}