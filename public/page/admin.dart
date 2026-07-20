import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project2/herbalife/public/constants/constants.dart';
import 'package:project2/herbalife/public/page/info.dart';
import 'package:project2/herbalife/public/page/user.dart';
import 'package:project2/herbalife/public/provider/auth_provider.dart';
import 'package:project2/herbalife/public/provider/cart_provider.dart';
import 'package:project2/herbalife/public/provider/profile_provider.dart';
import 'package:project2/herbalife/public/provider/product_provider.dart';
import 'package:project2/herbalife/public/widget/item.dart';
import 'package:provider/provider.dart';

class Admin extends StatefulWidget {
  final bool isclick;
  const Admin({super.key, this.isclick = true});

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> with TickerProviderStateMixin {
  bool isSelected = false;
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  // Admin Form Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _pointController = TextEditingController();
  XFile? _imageFile;

  final GlobalKey cartKey = GlobalKey();
  List<GlobalKey> itemKeys = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().getProfile();
      context.read<CartProvider>().fetchCartItems();
      context.read<ProductProvider>().getAllProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _pointController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = image;
      });
    }
  }

  Future<void> _submitProduct() async {
    final productProvider = context.read<ProductProvider>();
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _pointController.text.isEmpty ||
        _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select an image')),
      );
      return;
    }

    final success = await productProvider.createProduct(
      name: _nameController.text,
      price: _priceController.text,
      point: _pointController.text,
      imageFile: _imageFile!,
    );

    if (!mounted) return;

    if (success) {
      _nameController.clear();
      _priceController.clear();
      _pointController.clear();
      setState(() {
        _imageFile = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product created successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(productProvider.message ?? 'Failed to create product')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<Authprovider>();
    final cartProvider = context.watch<CartProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final productProvider = context.watch<ProductProvider>();

    final int totalQty = cartProvider.cartItems.fold(
      0,
      (sum, item) => sum + item.quantity,
    );

    final filteredProducts = productProvider.products
        .where(
          (product) =>
              product.name.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();

    // Dynamically update itemKeys to match filteredProducts length
    if (itemKeys.length != filteredProducts.length) {
      itemKeys = List.generate(filteredProducts.length, (index) => GlobalKey());
    }

    // Responsive sizing
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final isWideScreen = screenWidth > 600;

    final double maxContentWidth = isWideScreen ? 1200.0 : 500.0;
    final double horizontalPadding = (screenWidth * 0.05).clamp(16.0, 24.0);

    final int crossAxisCount = screenWidth > 1200
        ? 5
        : (screenWidth > 900 ? 4 : (isWideScreen ? 3 : 2));

    final double childAspectRatio = isWideScreen ? 0.68 : 0.53;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F1),
      body: Stack(
        children: [
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
                          if (profileProvider.role != 'admin')
                            _buildHeaderButton(
                              icon: Icons.help_outline_rounded,
                              label: isWideScreen ? "Help Center" : "Help",
                              color: Colors.white,
                              textColor: Colors.grey.shade700,
                              iconColor: const Color(0xFF43A047),
                              onTap: _showMyDialog,
                            ),
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
                          const SizedBox(width: 8),
                          _buildHeaderButton(
                            icon: Icons.person_outline_rounded,
                            label: "User List",
                            color: const Color(0xFF1B5E20),
                            textColor: Colors.white,
                            iconColor: Colors.white,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserListPage(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

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
                            productProvider.isLoading
                                ? "Fetching items..."
                                : "${filteredProducts.length} Products Available",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: productProvider.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: kPrimaryGreen,
                              ),
                            )
                          : CustomScrollView(
                              physics: const BouncingScrollPhysics(),
                              slivers: [
                                if (filteredProducts.isEmpty)
                                  SliverFillRemaining(
                                    hasScrollBody: false,
                                    child: Center(
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
                                    ),
                                  )
                                else
                                  SliverPadding(
                                    padding: EdgeInsets.fromLTRB(
                                      horizontalPadding,
                                      4,
                                      horizontalPadding,
                                      20,
                                    ),
                                    sliver: SliverGrid(
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        childAspectRatio: childAspectRatio,
                                        crossAxisSpacing: isWideScreen ? 24 : 12,
                                        mainAxisSpacing: isWideScreen ? 24 : 12,
                                      ),
                                      delegate: SliverChildBuilderDelegate(
                                        (context, index) {
                                          final product = filteredProducts[index];
                                          return ImageCounterCard(
                                            isclick: true,
                                            key: itemKeys[index],
                                            id: product.id.toString(),
                                            imagepath: product.imageUrl ?? "",
                                            product: product.name,
                                            price: product.price,
                                            point: product.point,
                                            onSelect: () => flyToCart(
                                              itemKeys[index],
                                              product.imageUrl ?? "",
                                            ),
                                            onSelect2: () => flyFromCart(
                                              itemKeys[index],
                                              product.imageUrl ?? "",
                                            ),
                                          );
                                        },
                                        childCount: filteredProducts.length,
                                      ),
                                    ),
                                  ),
                                SliverToBoxAdapter(
                                  child: _buildAdminForm(productProvider),
                                ),
                              ],
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

  Widget _buildAdminForm(ProductProvider productProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDCEEDC), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Add New Product",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 12),
          _buildFormTextField(_nameController, "Product Name", Icons.label_outline),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildFormTextField(_priceController, "Price", Icons.attach_money, isNumber: true)),
              const SizedBox(width: 8),
              Expanded(child: _buildFormTextField(_pointController, "Point", Icons.star_outline, isNumber: true)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image_outlined),
                  label: Text(_imageFile == null ? "Pick Image" : "Change Image"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF43A047),
                    side: const BorderSide(color: Color(0xFF43A047)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              if (_imageFile != null) ...[
                const SizedBox(width: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: kIsWeb 
                    ? Image.network(_imageFile!.path, width: 40, height: 40, fit: BoxFit.cover)
                    : Image.file(File(_imageFile!.path), width: 40, height: 40, fit: BoxFit.cover),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: productProvider.isLoading ? null : _submitProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF43A047),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: productProvider.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text("Create Product", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF43A047)),
        filled: true,
        fillColor: const Color(0xFFF8FBF8),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8F5E9), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF43A047), width: 1.5),
        ),
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
    if (itemKey.currentContext == null || cartKey.currentContext == null) {
      return;
    }
    final itemBox = itemKey.currentContext!.findRenderObject() as RenderBox;
    final itemPos = itemBox.localToGlobal(Offset.zero);
    final cartBox = cartKey.currentContext!.findRenderObject() as RenderBox;
    final cartPos = cartBox.localToGlobal(Offset.zero);

    _runFlyAnimation(itemPos, cartPos, imagePath);
  }

  void flyFromCart(GlobalKey itemKey, String imagePath) {
    if (itemKey.currentContext == null || cartKey.currentContext == null) {
      return;
    }
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
            child: _buildFlyImage(imagePath, sizeAnimation.value),
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

  Widget _buildFlyImage(String imagePath, double size) {
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        width: size,
        height: size,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.broken_image, size: size),
      );
    } else if (imagePath.isNotEmpty) {
      return Image.asset(
        imagePath,
        width: size,
        height: size,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.image, size: size),
      );
    } else {
      return Icon(Icons.image, size: size);
    }
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
