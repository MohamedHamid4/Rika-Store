class CartModel {
  final String id;
  final String brand;
  final String description;
  final String image;
  final double price;
  int quantity;

  CartModel({
    required this.id,
    required this.brand,
    required this.description,
    required this.image,
    required this.price,
    this.quantity = 1,
  });
}