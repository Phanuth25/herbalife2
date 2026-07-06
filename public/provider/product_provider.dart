import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project2/herbalife/public/constants/constants.dart';
import 'package:project2/herbalife/public/model/product_model.dart';

class ProductProvider extends ChangeNotifier {
  final Dio _dio = Dio();

  List<ProductItemModel> _products = [];
  bool isLoading = false;
  String? message;

  List<ProductItemModel> get products => _products;

  // 1. Fetch all products
  Future<void> getAllProducts() async {
    message = "";
    isLoading = true;
    notifyListeners();

    try {
      final response = await _dio.get("$accounturl/getpall");

      if (response.statusCode == 200) {
        final model = ProductResponseModel.fromJson(response.data);
        _products = model.data;
        debugPrint('Here:$_products');
        message = model.message.toString();
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data['message'] != null) {
        message = data['message'].toString();
      } else if (data is String && data.isNotEmpty) {
        message = data; // plain text error from server
      } else {
        message = "Failed to load products: ${e.message ?? 'Unknown error'}";
      }
      debugPrint('Error message:$message');
      debugPrint('Requesting: $accounturl/getallp');
    } catch (e) {
      message = "An error occurred: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 2. Create Product (Multipart/FormData)
  Future<bool> createProduct({
    required String name,
    required String price,
    required String point,
    required XFile imageFile,
  }) async {
    message = "";
    isLoading = true;
    notifyListeners();

    try {
      MultipartFile multipartFile;
      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        multipartFile = MultipartFile.fromBytes(bytes, filename: imageFile.name);
      } else {
        multipartFile = await MultipartFile.fromFile(imageFile.path, filename: imageFile.name);
      }

      FormData formData = FormData.fromMap({
        'name': name,
        'price': price,
        'point': point,
        'image': multipartFile, // Matches upload.single('image') in route
      });

      final response = await _dio.post("$accounturl/createp", data: formData);

      if (response.statusCode == 200) {
        message = "Product created successfully";
        await getAllProducts(); // Refresh the list
        return true;
      }
      return false;
    } on DioException catch (e) {
      message = e.response?.data['error'] ?? e.message;
      return false;
    } catch (e) {
      message = "Network failed: $e";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 3. Update Product
  Future<bool> updateProduct({
    required int id,
    required String name,
    required String price,
    required String point,
    String? existingImageUrl,
    XFile? newImageFile,
  }) async {
    message = "";
    isLoading = true;
    notifyListeners();

    try {
      Map<String, dynamic> data = {
        'id': id, // Controller extracts id from req.body
        'name': name,
        'price': price,
        'point': point,
        'image_url': existingImageUrl,
      };

      if (newImageFile != null) {
        if (kIsWeb) {
          final bytes = await newImageFile.readAsBytes();
          data['image'] = MultipartFile.fromBytes(bytes, filename: newImageFile.name);
        } else {
          data['image'] = await MultipartFile.fromFile(newImageFile.path, filename: newImageFile.name);
        }
      }

      FormData formData = FormData.fromMap(data);

      final response = await _dio.put("$accounturl/updatep", data: formData);

      if (response.statusCode == 200) {
        message = "Product updated successfully";
        await getAllProducts();
        return true;
      }
      return false;
    } on DioException catch (e) {
      message = e.response?.data['error'] ?? "Update failed";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 4. Delete Product
  Future<bool> deleteProduct(int id) async {
    message = "";
    isLoading = true;
    notifyListeners();

    try {
      final response = await _dio.delete("$accounturl/deletep/$id");

      if (response.statusCode == 200) {
        message = "Deleted successfully";
        _products.removeWhere((p) => p.id == id);
        notifyListeners();
        return true;
      }
      return false;
    } on DioException catch (e) {
      message = e.response?.data['message'] ?? "Delete failed";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
