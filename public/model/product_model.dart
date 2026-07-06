// Handles the whole API response for products
class ProductResponseModel {
  final bool success;
  final String message;
  final List<ProductItemModel> data;

  ProductResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ProductResponseModel.fromJson(Map<String, dynamic> json) {
    return ProductResponseModel(
      // Use "is bool" check instead of "as bool" for safer web performance
      success: json['success'] is bool ? json['success'] : (json['success'] == 1),

      // Use String.valueOf style logic
      message: json['message'] == null ? "" : "${json['message']}",

      data: (json['data'] as List?)
          ?.map((item) => ProductItemModel.fromJson(item))
          .toList() ??
          [],
    );
  }
}

// Handles each individual product item
class ProductItemModel {
  final int? id;
  final String name;
  final String price;
  final String point;
  final String? imageUrl;

  ProductItemModel({
    this.id,
    required this.name,
    required this.price,
    required this.point,
    this.imageUrl,
  });

  factory ProductItemModel.fromJson(Map<String, dynamic> json) {
    return ProductItemModel(
      // Safely parse ID even if it comes as a String or Int from JS
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ""),
      name: "${json['name'] ?? ""}",
      price: "${json['price'] ?? "0.00"}",
      point: "${json['point'] ?? "0"}",
      imageUrl: json['image_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'price': price,
      'point': point,
      'image_url': imageUrl,
    };
  }
}