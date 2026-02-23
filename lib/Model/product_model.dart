import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String brand;
  final String image;
  final double price;
  final DateTime createdAt;
  final String category;
  final String description;
  final bool isNewArrival;
  bool isFavorite;

  final List<String>? sizes;
  final List<String>? colors;

  ProductModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.image,
    required this.price,
    DateTime? createdAt,
    required this.category,
    required this.description,
    this.isNewArrival = false,
    this.isFavorite = false,
    this.sizes,
    this.colors,
  }) : this.createdAt = createdAt ?? DateTime.now();

  factory ProductModel.fromFirestore(Map<String, dynamic> json, String docId) {
    return ProductModel(
      id: docId,
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      image: json['image'] ?? '',
      category: json['category_key'] ?? 'general',
      description: json['description'] ?? '',
      price: (json['price'] != null)
          ? double.parse(json['price'].toString())
          : 0.0,
      isNewArrival: json['isNewArrival'] ?? false,
      isFavorite: json['isFavorite'] ?? false,

      sizes: json['sizes'] != null ? List<String>.from(json['sizes']) : null,
      colors: json['colors'] != null ? List<String>.from(json['colors']) : null,

      createdAt: (json['createdAt'] != null && json['createdAt'] is Timestamp)
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}

class CategoriesModel {
  final String id;
  final String title;
  final String image;
  final String productCount;

  CategoriesModel({
    required this.id,
    required this.title,
    required this.image,
    required this.productCount,
  });

  factory CategoriesModel.fromFirestore(
    Map<String, dynamic> json,
    String docId,
  ) {
    return CategoriesModel(
      id: docId,
      title: json['title'] ?? 'general',
      image: json['image'] ?? '',
      productCount: (json['productCount'] ?? '0').toString(),
    );
  }
}
