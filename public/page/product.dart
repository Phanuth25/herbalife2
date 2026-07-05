import 'package:flutter/material.dart';
import 'package:project2/herbalife/public/constants/constants.dart';
import 'package:project2/herbalife/public/model/product_model.dart';
import 'package:project2/herbalife/public/page/info.dart';
import 'package:project2/herbalife/public/provider/auth_provider.dart';
import 'package:project2/herbalife/public/provider/cart_provider.dart';
import 'package:project2/herbalife/public/provider/profile_provider.dart';
import 'package:project2/herbalife/public/widget/item.dart';
import 'package:project2/herbalife/public/page/cart.dart';
import 'package:provider/provider.dart';

class Product extends StatefulWidget {
  const Product({super.key});

  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> with TickerProviderStateMixin {
  bool isSelected = false;
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  final GlobalKey cartKey = GlobalKey();
  late List<GlobalKey> itemKeys;

  @override
  void initState() {
    super.initState();
    itemKeys = List.generate(products.length, (index) => GlobalKey());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().getProfile();
      context.read<CartProvider>().fetchCartItems();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<Authprovider>();
    final cartProvider = context.watch<CartProvider>();
    final profileProvider = context.watch<ProfileProvider>();

    final double totalPoint = cartProvider.totalPoints;
    final int totalQty = cartProvider.cartItems.fold(
      0,
      (sum, item) => sum + item.quantity,
    );

    final filteredProducts = products
        .where(
          (product) =>
              product.name.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();

    // Responsive sizing
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final isWideScreen = screenWidth > 600;

    // Adjusted maxContentWidth to allow for more columns on Web/Desktop
    final double maxContentWidth = isWideScreen ? 1200.0 : 500.0;
    final double horizontalPadding = (screenWidth * 0.05).clamp(16.0, 24.0);

    // 3. Universal Fix: Dynamic grid configuration
    // 2 columns for Mobile (<600), 3 for small tablets (600-900), 4 for Tablet/Web (900-1200), 5 for ultra-wide (>1200)
    final int crossAxisCount = screenWidth > 1200
        ? 5
        : (screenWidth > 900 ? 4 : (isWideScreen ? 3 : 2));

    // 1. Adjusted childAspectRatio to resolve overflow and maintain aesthetics
    // 0.60 for Mobile, 0.80 for Wide Screens
    final double childAspectRatio = isWideScreen ? 0.68 : 0.53;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F1),
      body: Stack(
        children: [
          // Scalable decorative background circles
          Positioned(
            top: -80,
            left: screenWidth > 1200
                ? screenWidth / 2 - 600
                : (screenWidth > 800 ? screenWidth / 2 - 400 : -60),
            child: _buildCircle(260, 0.09),
          ),
          Positioned(
            top: -40,
            right: screenWidth > 1200
                ? screenWidth / 2 - 550
                : (screenWidth > 800 ? screenWidth / 2 - 350 : -80),
            child: _buildCircle(200, 0.11),
          ),

          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Column(
                  children: [
                    // Responsive Header
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        12,
                        horizontalPadding,
                        8,
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/images/Herblogo.png",
                            height: (screenWidth * 0.08).clamp(30.0, 40.0),
                          ),
                          const Spacer(),
                          ...[
                            if (profileProvider.role == 'admin')
                              _buildHeaderButton(
                                icon: Icons.help_outline_rounded,
                                label: "Admin Page",
                                color: Colors.white,
                                textColor: Colors.grey.shade700,
                                iconColor: const Color(0xFF43A047),
                                onTap: _showMyDialog,
                              ),
                          ],
                          ...[
                            if (profileProvider.role != 'admin')
                              _buildHeaderButton(
                                icon: Icons.help_outline_rounded,
                                label: isWideScreen ? "Help Center" : "Help",
                                color: Colors.white,
                                textColor: Colors.grey.shade700,
                                iconColor: const Color(0xFF43A047),
                                onTap: _showMyDialog,
                              ),
                          ],
                          const SizedBox(width: 8),
                          _buildHeaderButton(
                            icon: Icons.exit_to_app_rounded,
                            label: "Back",
                            color: const Color(0xFF1B5E20),
                            textColor: Colors.white,
                            iconColor: Colors.white,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Info(authProvider.userId),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Responsive Search Bar
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: 10,
                      ),
                      child: TextFormField(
                        controller: _searchController,
                        onChanged: (value) =>
                            setState(() => searchQuery = value),
                        decoration: InputDecoration(
                          hintText: "Search products...",
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF43A047),
                          ),
                          suffixIcon: searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close_rounded),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => searchQuery = "");
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFFDCEEDC),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFF43A047),
                              width: 1.8,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Cart Banner
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: 10,
                      ),
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Cart()),
                        ),
                        child: Container(
                          width: double.infinity,
                          height: 70,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF2E7D32,
                                ).withValues(alpha: 0.30),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 18),
                              SizedBox(
                                width: 46,
                                height: 46,
                                child: Stack(
                                  key: cartKey,
                                  children: [
                                    const Positioned(
                                      top: 4,
                                      left: 0,
                                      child: Icon(
                                        Icons.shopping_cart_rounded,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                    Positioned(
                                      left: 18,
                                      top: 0,
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: const Color(0xFF43A047),
                                            width: 1.5,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '$totalQty',
                                          style: const TextStyle(
                                            color: Color(0xFF2E7D32),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "My Cart",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    "Points: ${totalPoint.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              const Padding(
                                padding: EdgeInsets.only(right: 18),
                                child: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.white70,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Product Count Label
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        0,
                        horizontalPadding,
                        6,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 16,
                            decoration: BoxDecoration(
                              color: kPrimaryGreen,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "${filteredProducts.length} Products Available",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Responsive Product Grid
                    Expanded(
                      child: filteredProducts.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off_rounded,
                                    size: 56,
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "No products found",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey.shade400,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              padding: EdgeInsets.fromLTRB(
                                horizontalPadding,
                                4,
                                horizontalPadding,
                                20,
                              ),
                              physics: const BouncingScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    childAspectRatio: childAspectRatio,
                                    crossAxisSpacing: isWideScreen ? 24 : 12,
                                    mainAxisSpacing: isWideScreen ? 24 : 12,
                                  ),
                              itemCount: filteredProducts.length,
                              itemBuilder: (context, index) {
                                final product = filteredProducts[index];
                                final keyIndex = index % itemKeys.length;
                                return ImageCounterCard(
                                  key: itemKeys[keyIndex],
                                  id: product.id.toString(),
                                  imagepath: product.image,
                                  product: product.name,
                                  price: product.price.toString(),
                                  point: product.point.toString(),
                                  onSelect: () => flyToCart(
                                    itemKeys[keyIndex],
                                    product.image,
                                  ),
                                  onSelect2: () => flyFromCart(
                                    itemKeys[keyIndex],
                                    product.image,
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircle(double size, double alpha) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF388E3C).withValues(alpha: alpha),
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color == Colors.white
                  ? Colors.black.withValues(alpha: 0.06)
                  : color.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void flyToCart(GlobalKey itemKey, String imagePath) {
    if (itemKey.currentContext == null || cartKey.currentContext == null)
      return;
    final itemBox = itemKey.currentContext!.findRenderObject() as RenderBox;
    final itemPos = itemBox.localToGlobal(Offset.zero);
    final cartBox = cartKey.currentContext!.findRenderObject() as RenderBox;
    final cartPos = cartBox.localToGlobal(Offset.zero);

    _runFlyAnimation(itemPos, cartPos, imagePath);
  }

  void flyFromCart(GlobalKey itemKey, String imagePath) {
    if (itemKey.currentContext == null || cartKey.currentContext == null)
      return;
    final itemBox = itemKey.currentContext!.findRenderObject() as RenderBox;
    final itemPos = itemBox.localToGlobal(Offset.zero);
    final cartBox = cartKey.currentContext!.findRenderObject() as RenderBox;
    final cartPos = cartBox.localToGlobal(Offset.zero);

    _runFlyAnimation(cartPos, itemPos, imagePath);
  }

  void _runFlyAnimation(Offset start, Offset end, String imagePath) {
    final animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    final posAnimation = Tween<Offset>(
      begin: start,
      end: end,
    ).animate(CurvedAnimation(parent: animController, curve: Curves.easeInOut));
    final sizeAnimation = Tween<double>(
      begin: 80,
      end: 10,
    ).animate(CurvedAnimation(parent: animController, curve: Curves.easeInOut));

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => AnimatedBuilder(
        animation: animController,
        builder: (context, child) {
          return Positioned(
            left: posAnimation.value.dx,
            top: posAnimation.value.dy,
            child: Image.asset(
              imagePath,
              width: sizeAnimation.value,
              height: sizeAnimation.value,
            ),
          );
        },
      ),
    );

    Overlay.of(context).insert(entry);
    animController.forward().then((_) {
      entry.remove();
      animController.dispose();
    });
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Items Saved in Cart',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Your selected products will remain in your cart even if you close the app.',
                ),
                SizedBox(height: 10),
                Text(
                  'To remove any items, please go to your Cart page and tap the trash icon.',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Understood',
                style: TextStyle(
                  color: Color(0xFF1B5E20),
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
