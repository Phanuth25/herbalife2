import 'package:flutter/material.dart';
import 'package:project2/herbalife/public/constants/constants.dart';
import 'package:provider/provider.dart';
import 'package:project2/herbalife/public/provider/cart_provider.dart';
import 'package:project2/herbalife/public/provider/profile_provider.dart';

class ImageCounterCard extends StatefulWidget {
  final String imagepath;
  final String product;
  final String price;
  final String point;
  final String id;
  final VoidCallback onSelect;
  final VoidCallback onSelect2;

  const ImageCounterCard({
    super.key,
    required this.imagepath,
    required this.product,
    required this.price,
    required this.point,
    required this.onSelect,
    required this.onSelect2,
    required this.id,
  });

  @override
  State<ImageCounterCard> createState() => _ImageCounterCardState();
}

class _ImageCounterCardState extends State<ImageCounterCard>
    with SingleTickerProviderStateMixin {
  AnimationController? _selectAnim;
  Animation<double>? _scaleAnim;

  @override
  void initState() {
    super.initState();
    final ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
    _selectAnim = ctrl;
    _scaleAnim = ctrl;
  }

  @override
  void dispose() {
    _selectAnim?.dispose();
    super.dispose();
  }

  double _getEffectivePrice(int discount) {
    final double originalPrice = double.tryParse(widget.price) ?? 0.0;
    if (discount > 0) {
      return originalPrice * (1 - discount / 100);
    }
    return originalPrice;
  }

  void _onTap() async {
    await _selectAnim?.reverse();
    _selectAnim?.forward();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final int userId = int.tryParse(profileProvider.id ?? '0') ?? 0;
    final int productId = int.tryParse(widget.id) ?? 0;

    final cartItem = cartProvider.cartItems
        .where((item) => item.product == productId)
        .firstOrNull;
    final bool isSelected = cartItem != null;
    final int currentCounter = cartItem?.quantity ?? 0;

    int discount = 0;
    if (profileProvider.discount != null) {
      discount = double.tryParse(profileProvider.discount!)?.toInt() ?? 0;
    }

    final double effectivePrice = _getEffectivePrice(discount);

    return ScaleTransition(
      scale: _scaleAnim ?? const AlwaysStoppedAnimation(1.0),
      child: GestureDetector(
        onTap: () async {
          final bool wasSelected = isSelected;
          _onTap();
          // first select
          if (!wasSelected) {
            // card is being selected → add item
            await cartProvider.postitem(userId, productId, 1);
            await cartProvider.plusinfos(double.parse(widget.point), profileProvider);
          } else {
            // card is being deselected → remove item
            final int? invoiceId = cartProvider.getInvoiceId(productId);
            if (invoiceId != null) {
              final double pointsToRemove = currentCounter * (double.tryParse(widget.point) ?? 0.0);
              await cartProvider.deleteitem(invoiceId);
              cartProvider.clearInvoiceId(productId);
              await cartProvider.minusinfos(pointsToRemove, profileProvider);
            }
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? kPrimaryGreen : const Color(0xFFDCEEDC),
              width: isSelected ? 2.0 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? const Color(0xFF388E3C).withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: isSelected ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 130,
                      color: const Color(0xFFF0F8F0),
                      child: Image.asset(
                        widget.imagepath,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ),
                    if (isSelected)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2E7D32),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    if (discount > 0)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade500,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "-$discount%",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                child: Column(
                  children: [
                    Text(
                      widget.product,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: "KhmerFont",
                        color: Color(0xFF1B5E20),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "\$${effectivePrice.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                        if (discount > 0) ...[
                          const SizedBox(width: 5),
                          Text(
                            "\$${double.parse(widget.price).toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade400,
                              decoration: TextDecoration.lineThrough,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.stars_rounded,
                            size: 12,
                            color: Color(0xFF43A047),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            "${widget.point} pts",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5FBF5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFDCEEDC),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // minus
                        GestureDetector(
                          onTap: () async {
                            final int? invoiceId = cartProvider.getInvoiceId(productId);
                            if (invoiceId == null || currentCounter <= 0) return;

                            if (currentCounter == 1) {
                              await cartProvider.deleteitem(invoiceId);
                              cartProvider.clearInvoiceId(productId);
                              await cartProvider.minusinfos(double.parse(widget.point), profileProvider);
                            } else {
                              await cartProvider.postitem2(invoiceId, currentCounter - 1);
                              await cartProvider.minusinfos(double.parse(widget.point), profileProvider);
                            }
                            widget.onSelect2();
                          },
                          child: Container(
                            width: 36,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                              ),
                            ),
                            child: const Icon(
                              Icons.remove_rounded,
                              color: Colors.red,
                              size: 18,
                            ),
                          ),
                        ),
                        Text(
                          '$currentCounter',
                          style: const TextStyle(
                            color: Color(0xFF1B5E20),
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        // plus
                        GestureDetector(
                          onTap: () async {
                            widget.onSelect();
                            if (!mounted) return; // ← add this guard before using widget/context
                            final int? invoiceId = cartProvider.getInvoiceId(productId);
                            if (invoiceId != null) {
                              await cartProvider.postitem2(invoiceId, currentCounter + 1);
                              if (!mounted) return; // ← add this guard before using widget/context
                              await cartProvider.plusinfos(double.parse(widget.point), profileProvider);

                              if(!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Row(
                                    children: [
                                      Icon(
                                        Icons.add_shopping_cart_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "Added to cart",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: const Color(0xFF2E7D32),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          child: Container(
                            width: 36,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: Color(0xFF2E7D32),
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
