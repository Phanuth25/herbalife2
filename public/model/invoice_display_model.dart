class InvoiceDisplayItem {
  final String name;
  final int quantity;
  final String point;
  final String total;
  final bool isPurchased;

  InvoiceDisplayItem({
    required this.name,
    required this.quantity,
    required this.point,
    required this.total,
    this.isPurchased = false,
  });
}
