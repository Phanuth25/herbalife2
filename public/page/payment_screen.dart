import 'dart:async';
import 'package:flutter/material.dart';
import 'package:project2/herbalife/public/provider/profile_provider.dart';
import 'package:project2/herbalife/public/provider/khqr_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
    _setup();
  }

  Future<void> _setup() async {
    final khqr = context.read<KhqrProvider>();
    final auth2 = context.read<ProfileProvider>();

    // await because generateQR is now async
    await khqr.generateQR(
      bakongID:  'kimhak@dev',      // replace with your actual Bakong ID
      merchantName: auth2.isname,
      amount: widget.amount,
      billNumber: widget.billNumber,
    );

    // Don't start timers if generation failed
    if (khqr.qrString == null) return;

    // Poll every 3 seconds
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

    return Scaffold(
      appBar: AppBar(title: const Text('Scan to Pay')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _buildBody(khqr),
        ),
      ),
    );
  }

  Widget _buildBody(KhqrProvider khqr) {
    // Generating QR or checking payment
    if (khqr.isLoading) {
      return const CircularProgressIndicator();
    }

    // Generation failed
    if (khqr.qrString == null && !khqr.isExpired && !khqr.isPaid) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 80),
          const SizedBox(height: 16),
          Text(khqr.message ?? 'Failed to generate QR'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _setup(),
            child: const Text('Try Again'),
          ),
        ],
      );
    }

    // Payment confirmed
    if (khqr.isPaid) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 100),
          const SizedBox(height: 16),
          const Text('Payment Confirmed!'),
          const SizedBox(height: 4),
          Text('\$${widget.amount.toStringAsFixed(2)} received'),
        ],
      );
    }

    // QR expired
    if (khqr.isExpired) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_off, color: Colors.red, size: 80),
          const SizedBox(height: 16),
          const Text('QR code expired.'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              khqr.reset();
              _setup();
            },
            child: const Text('Generate New QR'),
          ),
        ],
      );
    }

    // QR ready — waiting for payment
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '\$${widget.amount.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        const Text('Open your Bakong app and scan'),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: QrImageView(
            data: khqr.qrString!,
            version: QrVersions.auto,
            size: 260,
            errorCorrectionLevel: QrErrorCorrectLevel.M,
          ),
        ),
        const SizedBox(height: 20),
        const CircularProgressIndicator(),
        const SizedBox(height: 8),
        Text(khqr.message ?? 'Waiting for payment...'),
      ],
    );
  }
}