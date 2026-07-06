import 'package:flutter/material.dart';
import 'package:project2/herbalife/public/constants/constants.dart';
import 'package:provider/provider.dart';
import 'package:project2/herbalife/public/provider/cart_provider.dart';
import 'package:project2/herbalife/public/provider/profile_provider.dart';
import '../provider/data_provider.dart';

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

  Widget _buildProductImage(double height) {
    if (widget.imagepath.startsWith('http')) {
      return Image.network(
        widget.imagepath,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50),
      );
    } else if (widget.imagepath.isNotEmpty) {
      return Image.asset(
        widget.imagepath,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 50),
      );
    } else {
      return const Icon(Icons.image, size: 50);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final dataProvider = Provider.of<SecureStorageProvider>(context);
    final userIdFuture = dataProvider.readSecureData('userId');
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

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWideScreen = screenWidth > 600;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = constraints.maxWidth;
        final double cardPadding = (cardWidth * 0.08).clamp(8.0, 12.0);
        final double titleFontSize = (cardWidth * 0.10).clamp(10.0, 12.0);
        final double priceFontSize = (cardWidth * 0.11).clamp(12.0, 14.0);
        final double imageHeight = (cardWidth * 0.75).clamp(80.0, 100.0);

        return ScaleTransition(
          scale: _scaleAnim ?? const AlwaysStoppedAnimation(1.0),
          child: GestureDetector(
            onTap: () async {
              final userId = await userIdFuture;
              if (userId == null || userId == 0) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please login first")),
                );
                return;
              }

              final bool wasSelected = isSelected;
              _onTap();

              if (!wasSelected) {
                await cartProvider.postitem(userId, productId, 1);
              } else {
                final int? invoiceId = cartProvider.getInvoiceId(productId);
                if (invoiceId != null) {
                  await cartProvider.deleteitem(invoiceId);
                  cartProvider.clearInvoiceId(productId);
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
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: imageHeight,
                          color: const Color(0xFFF0F8F0),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _buildProductImage(imageHeight),
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
                              child: const Icon(Icons.check_rounded, color: Colors.white, size: 12),
                            ),
                          ),
                        if (discount > 0)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.red.shade600,
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
                    padding: EdgeInsets.fromLTRB(cardPadding, 8, cardPadding, 0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: titleFontSize * 1.3 * 2,
                          child: Text(
                            widget.product,
                            textAlign: isWideScreen ? TextAlign.center : TextAlign.left,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: "KhmerFont",
                              color: const Color(0xFF1B5E20),
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: isWideScreen ? MainAxisAlignment.center : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "\$${effectivePrice.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: priceFontSize,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1B5E20),
                              ),
                            ),
                            if (discount > 0) ...[
                              const SizedBox(width: 5),
                              Text(
                                "\$${double.parse(widget.price).toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: priceFontSize * 0.75,
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
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.stars_rounded, size: 12, color: Color(0xFF43A047)),
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
                  const Spacer(),
                  if (isSelected)
                    Padding(
                      padding: EdgeInsets.fromLTRB(cardPadding, 0, cardPadding, 10),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 140),
                          child: Container(
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5FBF5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFDCEEDC), width: 1.5),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    final int? invoiceId = cartProvider.getInvoiceId(productId);
                                    if (invoiceId == null || currentCounter <= 0) return;

                                    if (currentCounter == 1) {
                                      await cartProvider.deleteitem(invoiceId);
                                      cartProvider.clearInvoiceId(productId);
                                    } else {
                                      await cartProvider.postitem2(invoiceId, currentCounter - 1);
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
                                    child: const Icon(Icons.remove_rounded, color: Colors.red, size: 18),
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
                                GestureDetector(
                                  onTap: () async {
                                    widget.onSelect();
                                    final int? invoiceId = cartProvider.getInvoiceId(productId);
                                    if (invoiceId != null) {
                                      await cartProvider.postitem2(invoiceId, currentCounter + 1);
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
                                    child: const Icon(Icons.add_rounded, color: Color(0xFF2E7D32), size: 18),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
