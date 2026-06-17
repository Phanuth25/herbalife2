// Handles the whole API response
class CartModel {
  final bool success;
  final String message;
  final List<CartItemModel> data;

  CartModel({required this.success, required this.message, required this.data});

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List)
          .map((item) => CartItemModel.fromJson(item))
          .toList(),
    );
  }
}

// Handles each individual cart item
class CartItemModel {
  final int id;
  final String name;
  final int product;
  int quantity;
  final String total;
  String point;
  final DateTime datetime;

  CartItemModel({
    required this.id,
    required this.name,
    required this.product,
    required this.quantity,
    required this.total,
    required this.point,
    required this.datetime,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as int,
      name: json['name'] as String,
      product: json['product'] as int,
      quantity: json['quantity'] as int,
      total: json['total'] as String,
      point: json['point'] as String,
      datetime: DateTime.parse(json['datetime'] as String),
    );
  }
}
