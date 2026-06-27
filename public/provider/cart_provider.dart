import 'package:flutter/material.dart';
import 'package:project2/herbalife/public/model/cart_model.dart';
import 'package:project2/herbalife/public/provider/data_provider.dart';
import 'package:project2/herbalife/public/constants/constants.dart';
import 'package:dio/dio.dart';
import 'package:project2/herbalife/public/provider/profile_provider.dart';
import 'package:project2/herbalife/public/service/dio_client.dart';

import 'package:project2/herbalife/public/model/invoice_model.dart';

class CartProvider extends ChangeNotifier {
  final SecureStorageProvider dataProvider = SecureStorageProvider();
  final Dio _dio = DioClient.instance;
  String? message;
  bool isLoading = false;
  String? userId; // Member ID
  int? invoiceId;
  double totalPoints = 0.0;
  double totalPoint = 0.0; // for purchased point
  double totalPrice = 0.0; // for purchased price
  List<CartItemModel> cartItems = [];
  List<InvoiceItemModel> invoiceItems = [];
  Map<int, int> productInvoiceMap = {};

  void saveInvoiceId(int productId, int invoiceId) {
    productInvoiceMap[productId] = invoiceId;
    notifyListeners();
  }

  int? getInvoiceId(int productId) => productInvoiceMap[productId];

  void clearInvoiceId(int productId) {
    productInvoiceMap.remove(productId);
    notifyListeners();
  }

  Future<void> fetchCartItems() async {
    isLoading = true;
    notifyListeners();
    try {
      userId ??= await dataProvider.readSecureData('userId');
      if (userId == null) return;

      // The DioClient interceptor auto-injects the token here
      final response = await _dio.get('$accounturl/getitem/$userId');
      if (response.statusCode == 200) {
        final cart = CartModel.fromJson(response.data);
        cartItems = cart.data;
        totalPoints = cartItems.fold(
          0.0,
          (sum, item) =>
              sum + (double.tryParse(item.point) ?? 0.0) * item.quantity,
        );
        message = cart.message;

        productInvoiceMap.clear();
        for (var item in cartItems) {
          productInvoiceMap[item.product] = item.id;
        }
      } else {
        cartItems = [];
        totalPoints = 0.0;
      }
    } catch (e) {
      cartItems = [];
      totalPoints = 0.0;
    } finally {
      isLoading = false;
      notifyListeners(); // Enforces a visual refresh
    }
  }

  Future<void> postitem(String? userid, int product, int quantity) async {
    message = "";
    invoiceId = null;
    try {
      // Clean call: DioClient takes care of authorization headers behind the scenes
      final response = await _dio.post(
        "$accounturl/postitem",
        data: {'userid': userid, 'product': product, 'quantity': quantity},
      );
      if (response.statusCode == 200) {
        message = response.data['message'];
        invoiceId = response.data['invoiceId'];
        if (invoiceId != null) {
          saveInvoiceId(product, invoiceId!);
        }
        await fetchCartItems(); // Triggers items reload and forces green border
      }
    } catch (e) {
      message = "Network failed: $e";
    } finally {
      notifyListeners();
    }
  }

  Future<void> postitem2(int invoiceid, int quantity) async {
    try {
      final response = await _dio.patch(
        "$accounturl/postquantity",
        data: {'invoiceid': invoiceid, 'quantity': quantity},
      );
      if (response.statusCode == 200) {
        await fetchCartItems();
      }
    } catch (e) {
      print("Update quantity failed: $e");
    } finally {
      notifyListeners();
    }
  }

  Future<void> deleteitem(int invoiceId) async {
    try {
      final response = await _dio.delete(("$accounturl/deleteitem/$invoiceId"));
      if (response.statusCode == 200) {
        await fetchCartItems();
      }
    } catch (e) {
      print("Delete item failed: $e");
    } finally {
      notifyListeners();
    }
  }

  Future<void> plusinfos(double point, ProfileProvider profileProvider) async {
    try {
      String? infoId = await dataProvider.readSecureData('infoId');
      if (infoId == null) return;

      final response = await _dio.patch(
        '$accounturl/plusinfos',
        data: {'id': infoId, 'point': point},
      );
      if (response.statusCode == 200) {
        await profileProvider.getProfile();
      }
    } catch (e) {
      print("Plus point failed: $e");
    } finally {
      notifyListeners();
    }
  }

  Future<void> minusinfos(double point, ProfileProvider profileProvider) async {
    try {
      String? infoId = await dataProvider.readSecureData('infoId');
      if (infoId == null) return;

      final response = await _dio.patch(
        '$accounturl/removeinfos',
        data: {'id': infoId, 'point': point},
      );
      if (response.statusCode == 200) {
        await profileProvider.getProfile();
      }
    } catch (e) {
      print("Minus point failed: $e");
    } finally {
      notifyListeners();
    }
  }

  Future<void> ispurchase() async {
    final userId = await dataProvider.readSecureData('userId');
    isLoading = true;
    message = '';
    if (userId == null) return;
    try {
      final result = await _dio.patch('$accounturl/markaspurchased/$userId');
      if (result.statusCode == 200) {
        message = result.data['message'];
      } else {
        message = 'Purchase failed';
        debugPrint(result.data['message']);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectPurchased() async {
    message = '';
    isLoading = true;
    try {
      final userId = await dataProvider.readSecureData('userId');
      if (userId == null) return;
      final result = await _dio.get('$accounturl/selectpurchased/$userId');
      if (result.statusCode == 200) {
        final invoice = InvoiceModel.fromJson(result.data);
        invoiceItems = invoice.data;
        message = result.data['message'];
        totalPoint = invoiceItems.fold(
          0,
          (sum, item) => sum + double.parse(item.point),
        );
        totalPrice = invoiceItems.fold(
          0,
          (sum, item) => sum + double.parse(item.total),
        );
      } else {
        message = 'Purchase failed';
        debugPrint(result.data['message']);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
