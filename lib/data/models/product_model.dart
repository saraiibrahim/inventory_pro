class ProductModel {
  final int id;
  final String name;
  final String sku;
  final double price;
  final double costPrice;
  final int quantity;
  final String category;
  final String image;

  ProductModel({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.costPrice,
    required this.quantity,
    required this.category,
    required this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'price': price,
      'costPrice': costPrice,
      'quantity': quantity,
      'category': category,
      'image': image,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      sku: map['sku'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      costPrice: map['costPrice']?.toDouble() ?? 0.0,
      quantity: map['quantity']?.toInt() ?? 0,
      category: map['category'] ?? '',
      image: map['image'] ?? '',
    );
  }

  ProductModel copyWith({
    int? id,
    String? name,
    String? sku,
    double? price,
    double? costPrice,
    int? quantity,
    String? category,
    String? image,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      image: image ?? this.image,
    );
  }
}
