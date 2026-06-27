// Handles the whole API response
class InvoiceModel {
  final bool success;
  final String message;
  final List<InvoiceItemModel> data;

  InvoiceModel({required this.success, required this.message, required this.data});

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? "",
      data: (json['data'] as List?)
          ?.map((item) => InvoiceItemModel.fromJson(item))
          .toList() ??
          [],
    );
  }
}

// Handles each individual cart item
class InvoiceItemModel {
  final String name;
  final String product;
  final int userid;
  int quantity;
  String point;
  final String total;

  InvoiceItemModel({
    required this.name,
    required this.product,
    required this.userid,
    required this.quantity,
    required this.point,
    required this.total,
  });

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      name: json['name']?.toString() ?? "",
      product: json['product']?.toString() ?? "",
      userid: int.tryParse(json['userid'].toString()) ?? 0,
      quantity: int.tryParse(json['quantity'].toString()) ?? 0,
      point: json['point']?.toString() ?? "0",
      total: json['total']?.toString() ?? "0.00",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'product': product,
      'userid': userid,
      'quantity': quantity,
      'point': point,
      'total': total,
    };
  }

}