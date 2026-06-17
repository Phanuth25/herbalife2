import 'package:flutter/material.dart';
import 'package:project2/herbalife/public/constants/constants.dart';
import 'package:project2/herbalife/public/model/product_model.dart';
import 'package:project2/herbalife/public/page/info.dart';
import 'package:project2/herbalife/public/provider/auth_provider.dart';
import 'package:project2/herbalife/public/provider/cart_provider.dart';
import 'package:project2/herbalife/public/widget/item.dart';
import 'package:project2/herbalife/public/page/cart.dart';
import 'package:provider/provider.dart';

class Product extends StatefulWidget {
  const Product( {super.key});

  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> with TickerProviderStateMixin {
  bool isSelected = false;
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  final GlobalKey cartKey = GlobalKey();
  List<GlobalKey> itemKeys = List.generate(
    products.length,
    (index) => GlobalKey(),
  );

  @override
  void initState() {
    super.initState();
    context.read<CartProvider>().fetchCartItems();
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
    final double totalPoint = cartProvider.cartItems.fold(
      0,
      (sum, item) => sum + double.parse(item.point),
    );
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

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F1),
      body: Stack(
        children: [
          // ── decorative circles ───────────────────────────────────────
          Positioned(
            top: -80,
            left: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF388E3C).withValues(alpha: 0.09),
              ),
            ),
          ),
          Positioned(
            top: -40,
            right: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF81C784).withValues(alpha: 0.11),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── custom header ────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
                  child: Row(
                    children: [
                      // logo
                      Image.asset("assets/images/Herblogo.png", height: 36),
                      const Spacer(),

                      // Help button
                      GestureDetector(
                        onTap: () {
                          _showMyDialog();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.help_outline_rounded,
                                size: 16,
                                color: Color(0xFF43A047),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "Help",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Exit button
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              //here
                              builder: (context) => Info(authProvider.userId),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B5E20),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF1B5E20,
                                ).withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.exit_to_app_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                              SizedBox(width: 5),
                              Text(
                                "Back",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── search bar ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
                  child: TextFormField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => searchQuery = value),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: "Search products...",
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: Color(0xFF43A047),
                      ),
                      suffixIcon: searchQuery.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() => searchQuery = "");
                              },
                              child: Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: Colors.grey.shade400,
                              ),
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

                // ── cart banner ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Cart()),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
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
                          // cart icon + badge
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
                                      //here
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
                                "Points:$totalPoint",
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

                // ── product count label ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
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
                        "${filteredProducts.length} Products",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── product grid ─────────────────────────────────────────
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
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                          physics: const BouncingScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.52,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
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
                              onSelect: () =>
                                  flyToCart(itemKeys[keyIndex], product.image),
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
        ],
      ),
    );
  }

  void flyToCart(GlobalKey itemKey, String imagePath) {
    if (itemKey.currentContext == null) return;
    final itemBox = itemKey.currentContext!.findRenderObject() as RenderBox;
    final itemPos = itemBox.localToGlobal(Offset.zero);

    if (cartKey.currentContext == null) return;
    final cartBox = cartKey.currentContext!.findRenderObject() as RenderBox;
    final cartPos = cartBox.localToGlobal(Offset.zero);

    final animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    final posAnimation = Tween<Offset>(
      begin: itemPos,
      end: cartPos,
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

  void flyFromCart(GlobalKey itemKey, String imagePath) {
    if (itemKey.currentContext == null) return;
    final itemBox = itemKey.currentContext!.findRenderObject() as RenderBox;
    final itemPos = itemBox.localToGlobal(Offset.zero);

    if (cartKey.currentContext == null) return;
    final cartBox = cartKey.currentContext!.findRenderObject() as RenderBox;
    final cartPos = cartBox.localToGlobal(Offset.zero);

    final animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    final posAnimation = Tween<Offset>(
      begin: cartPos,
      end: itemPos,
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
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Items Saved in Cart'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Your selected products will remain in your cart even if you close the app.'),
                SizedBox(height: 10), // Added for better spacing
                Text('To remove any items, please go to your Cart page and tap the trash icon.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Understood'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
