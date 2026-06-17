import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:khqr_sdk/khqr_sdk.dart';
import 'dart:convert';

class KhqrProvider extends ChangeNotifier {
  String? message;
  bool isLoading = false;

  String? qrString;
  String? md5Hash;
  bool isPaid = false;
  bool isExpired = false;

  // Generate QR code locally using the SDK (no API call needed)
  // CHANGE: Changed to async and returns Future<void>
  Future<void> generateQR({
    required String bakongID,
    required String merchantName,
    required double amount,
    String city = 'Phnom Penh',
    String? billNumber,
  }) async {
    message = "";
    isPaid = false;
    isExpired = false;
    isLoading = true;
    notifyListeners();

    try {
      final info = IndividualInfo(
        // CHANGE: Fixed parameter name from bakongAccountID to bakongAccountId
        bakongAccountId: bakongID,
        merchantName: merchantName,
        merchantCity: city,
        amount: amount,
        // CHANGE: Fixed enum name from KHQRCurrency to KhqrCurrency
        currency: KhqrCurrency.usd,
        billNumber: billNumber,
        // Add this line
        expirationTimestamp: DateTime.now().millisecondsSinceEpoch + (2 * 60 * 1000),
      );

      // CHANGE: Changed BakongKHQR() to KhqrSdk() and added await
      final result = await KhqrSdk().generateIndividual(info);

      // CHANGE: Updated result handling to match KhqrData structure
      if (result != null) {
        qrString = result.qr;
        md5Hash = result.md5;
        message = "QR generated";
      } else {
        message = "Failed to generate QR";
        qrString = null;
        md5Hash = null;
      }
    } catch (e) {
      message = "Error generating QR: $e";
      qrString = null;
      md5Hash = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  final String bakongToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkYXRhIjp7ImlkIjoiOWUyOTA5OTg5Njc2NDE1OCJ9LCJpYXQiOjE3NzcyNTg0MDAsImV4cCI6MTc4NTAzNDQwMH0.dMc7bQK-FJUZ-KA67OWgoPHcAKzrOQqquAtXcL8qyH0";
  // Check payment status using md5 hash
  Future<void> checkPayment() async {
    if (md5Hash == null) return;
    message = "";
    isLoading = true;
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse("https://api-bakong.nbc.gov.kh/v1/check_transaction_by_md5"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $bakongToken',
          'Accept': 'application/json',
        },
        body: jsonEncode({'md5': md5Hash}),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        message = data['message'];
        isPaid = data['responseCode'] == 0;
      } else {
        message = data['message'] ?? "Failed to check payment";
        isPaid = false;
      }
    } catch (e) {
      message = "Network failed: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setExpired() {
    isExpired = true;
    isPaid = false;
    notifyListeners();
  }

  void reset() {
    qrString = null;
    md5Hash = null;
    isPaid = false;
    isExpired = false;
    message = "";
    notifyListeners();
  }
}
