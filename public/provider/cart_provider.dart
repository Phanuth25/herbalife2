import 'package:flutter/material.dart';
import 'package:project2/herbalife/public/model/cart_model.dart';
import 'package:project2/herbalife/public/provider/data_provider.dart';
import 'package:project2/herbalife/public/constants/constants.dart';
import 'package:dio/dio.dart';
import 'package:project2/herbalife/public/provider/profile_provider.dart';
import 'package:project2/herbalife/public/service/dio_client.dart';

class CartProvider extends ChangeNotifier {
  final SecureStorageProvider dataProvider = SecureStorageProvider();
  final Dio _dio = DioClient.instance;
  String? message;
  bool isLoading = false;
  String? id;
  int? invoiceId;
  int cartCount = 0;
  double point = 0.0;
  List<CartItemModel> cartItems = [];
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
      id ??= await dataProvider.readSecureData('userId');
      final response = await _dio.get(('$accounturl/getitem/$id'));
      final data = response.data;
      if (response.statusCode == 200) {
        final cart = CartModel.fromJson(data);
        cartItems = cart.data;
        // Sum up total points: unit point * quantity
        point = cartItems.fold(0.0, (sum, item) => sum + (double.tryParse(item.point) ?? 0.0) * item.quantity);
        message = cart.message;
      } else {
        cartItems = [];
        point = 0.0;
        message = data['message'];
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        cartItems = [];
        point = 0.0;
        message = e.response?.data['message'] ?? "Failed";
      } else {
        message = "Network error: $e";
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> postitem(int userid, int product, int quantity) async {
    message = "";
    invoiceId = null;
    try {
      final response = await _dio.post(
        ("$accounturl/postitem"),
        data: {'userid': userid, 'product': product, 'quantity': quantity},
      );
      final data = response.data;
      if (response.statusCode == 200) {
        message = data['message'];
        invoiceId = data['invoiceId'];
        saveInvoiceId(product, invoiceId!);
        await fetchCartItems();
      } else {
        message = data['message'];
        invoiceId = null;
      }
    } catch (e) {
      message = "Network failed: $e";
      invoiceId = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> postitem2(int invoiceid, int quantity) async {
    message = "";
    invoiceId = null;
    try {
      final response = await _dio.patch(
        "$accounturl/postquantity",
        data: {'invoiceid': invoiceid, 'quantity': quantity},
      );
      final data = response.data;
      if (response.statusCode == 200) {
        message = data['message'];
        await fetchCartItems();
      } else {
        message = data['message'];
      }
    } catch (e) {
      message = "Network failed: $e";
      invoiceId = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteitem(int invoiceId) async {
    message = "";
    isLoading = true;
    notifyListeners();
    try {
      final response = await _dio.delete(("$accounturl/deleteitem/$invoiceId"));
      final data = response.data;
      if (response.statusCode == 200) {
        message = data['message'];
        await fetchCartItems();
      } else {
        message = data['message'];
      }
    } catch (e) {
      message = "Network failed: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> plusinfos(double point, ProfileProvider profileProvider) async {
    message = "";
    try {
      id ??= await dataProvider.readSecureData('userId');
      final response = await _dio.patch(
        '$accounturl/plusinfos',
        data: {'id': id, 'point': point},
      );
      if (response.statusCode == 200) {
        await profileProvider.getProfile();
      }
    } catch (e) {
      message = "Network failed: $e";
    } finally {
      notifyListeners();
    }
  }

  Future<void> minusinfos(double point, ProfileProvider profileProvider) async {
    message = "";
    try {
      id ??= await dataProvider.readSecureData('userId');
      final response = await _dio.patch(
        '$accounturl/removeinfos',
        data: {'id': id, 'point': point},
      );
      if (response.statusCode == 200) {
        await profileProvider.getProfile();
      }
    } catch (e) {
      message = "Network failed: $e";
    } finally {
      notifyListeners();
    }
  }
}
