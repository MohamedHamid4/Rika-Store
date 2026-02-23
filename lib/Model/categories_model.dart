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

  factory CategoriesModel.fromFirestore(Map<String, dynamic> json, String docId) {
    return CategoriesModel(
      id: docId,
      title: json['title'] ?? 'general',
      image: json['image'] ?? '',
      productCount: (json['productCount'] ?? '0').toString(),
    );
  }
}