import 'dart:async';
import 'package:flutter/material.dart';
import 'package:project2/herbalife/public/provider/profile_provider.dart';
import 'package:project2/herbalife/public/provider/khqr_provider.dart';
import 'package:provider/provider.dart';
import 'package:project2/herbalife/public/provider/cart_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../data/notifier.dart';
import '../model/invoice_display_model.dart';
import '../widget/button.dart';
import 'invoice_screen.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  final String billNumber;

  const PaymentScreen({
    super.key,
    required this.amount,
    required this.billNumber,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  Timer? _pollingTimer;
  Timer? _expiryTimer;

  @override
  void initState() {
    super.initState();
    // Reset the purchase state notifier when entering the screen
    isPurchcase.value = false;
    _setup();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
    });
  }

  Future<void> _setup() async {
    final khqr = context.read<KhqrProvider>();
    final auth2 = context.read<ProfileProvider>();
    // await because generateQR is now async
    await khqr.generateQR(
      bakongID: 'kimhak@dev', // replace with your actual Bakong ID
      merchantName: auth2.isname,
      amount: widget.amount,
      billNumber: widget.billNumber,
    );

    // Don't start timers if generation failed
    if (khqr.qrString == null) return;

    // Poll every 5 minutes (as per 300s in original code, though usually it's faster)
    _pollingTimer = Timer.periodic(const Duration(seconds: 300), (_) async {
      await khqr.checkPayment();
      if (khqr.isPaid) {
        _pollingTimer?.cancel();
        _expiryTimer?.cancel();
      }
    });

    // Stop after 2 minutes
    _expiryTimer = Timer(const Duration(minutes: 2), () {
      if (!khqr.isPaid) {
        _pollingTimer?.cancel();
        khqr.setExpired();
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _expiryTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final khqr = context.watch<KhqrProvider>();
    
    // Responsive sizing
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final isWideScreen = screenWidth > 600;
    final horizontalPadding = (screenWidth * 0.08).clamp(16.0, 40.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan to Pay'),
        centerTitle: isWideScreen,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
            child: _buildBody(khqr, isWideScreen),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(KhqrProvider khqr, bool isWideScreen) {
    final cartProvider = context.watch<CartProvider>();
    final double qrSize = (MediaQuery.of(context).size.width * 0.6).clamp(200.0, 280.0);

    // Generating QR or checking payment
    if (khqr.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Generation failed
    if (khqr.qrString == null && !khqr.isExpired && !khqr.isPaid) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 80),
          const SizedBox(height: 16),
          Text(
            khqr.message ?? 'Failed to generate QR',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _setup(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Try Again'),
            ),
          ),
        ],
      );
    }

    // Payment confirmed
    if (khqr.isPaid) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 100),
          const SizedBox(height: 16),
          const Text(
            'Payment Confirmed!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${widget.amount.toStringAsFixed(2)} received',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ],
      );
    }

    // QR expired
    if (khqr.isExpired) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer_off, color: Colors.red, size: 80),
          const SizedBox(height: 16),
          const Text(
            'QR code expired.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                khqr.reset();
                _setup();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Generate New QR'),
            ),
          ),
        ],
      );
    }

    // QR ready — waiting for payment
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '\$${widget.amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Open your Bakong app and scan',
            textAlign: isWideScreen ? TextAlign.center : TextAlign.left,
            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: QrImageView(
              data: khqr.qrString!,
              version: QrVersions.auto,
              size: qrSize,
              errorCorrectionLevel: QrErrorCorrectLevel.M,
            ),
          ),
          const SizedBox(height: 32),
          const CircularProgressIndicator(strokeWidth: 3),
          const SizedBox(height: 16),
          Text(
            khqr.message ?? 'Waiting for payment...',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 40),
          MoviePassButton(
            onPressed: () async {
              if (isPurchcase.value == true) return;
              isPurchcase.value = true;

              await cartProvider.ispurchase();
              if (!mounted) return;
              
              if (cartProvider.message == 'successfully') {
                context.read<CartProvider>().selectPurchased();
                _showSuccessDialog(context, cartProvider);
              } else {
                _showErrorDialog(context, cartProvider);
              }
            },
            child: ValueListenableBuilder<bool>(
              valueListenable: isPurchcase,
              builder: (context, loading, child) {
                if (loading) {
                  return const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  );
                }
                return const Text("Confirm Purchase");
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, CartProvider cartProvider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            "Purchase Successful!",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                isPurchcase.value = false;
                Navigator.pop(dialogContext); // Close dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InvoiceScreen(
                      showHomeButton: true,
                      billNumber: "CART-${DateTime.now().millisecondsSinceEpoch}",
                      totalPrice: cartProvider.totalPrice,
                      totalPoint: cartProvider.totalPoint,
                      items: cartProvider.invoiceItems
                          .map((item) => InvoiceDisplayItem(
                                name: item.name,
                                quantity: item.quantity,
                                point: item.point,
                                total: item.total,
                                isPurchased: true,
                              ))
                          .toList(),
                    ),
                  ),
                );
              },
              child: const Text("See the invoice"),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, CartProvider cartProvider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            "Purchase Failed",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          content: Text(
            cartProvider.message ?? "Something went wrong. Please try again.",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                isPurchcase.value = false;
              },
              child: const Text("Try Again"),
            ),
          ],
        );
      },
    );
  }
}
