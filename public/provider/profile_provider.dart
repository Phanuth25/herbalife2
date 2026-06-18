import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project2/herbalife/public/provider/data_provider.dart';
import 'package:project2/herbalife/public/constants/constants.dart';
import 'package:project2/herbalife/public/service/dio_client.dart';

class ProfileProvider extends ChangeNotifier {
  final SecureStorageProvider dataProvider = SecureStorageProvider();
  final Dio _dio = DioClient.instance;
  String? message;
  bool isLoading = false;

  // Profile data
  String? email;
  String? phone;
  String? address;
  String? name;
  String? point;
  String? position;
  String? discount;
  String? photo;
  String? totalPoint;
  String? totalAmount;
  String? userId; // Store as String (Member ID)
  String? id; // Store as String (Database Primary Key)

  String get isemail => email ?? "No data";
  String get isphone => phone ?? "No data";
  String get isaddress => address ?? "No data";
  String get isname => name ?? "No data";
  String get ispoint => point ?? "No data";
  String get isposition => position ?? "No data";
  String get isdiscount => discount ?? "No data";

  Future<void> getProfile() async {
    message = "";
    isLoading = true;
    notifyListeners();

    try {
      userId ??= await dataProvider.readSecureData('userId');
      debugPrint('userId: $userId');
      final response = await _dio.get(("$accounturl/profile/$userId"));
      final data = response.data;
      if (response.statusCode == 200) {
        id = data['id']?.toString();
        message = data['message'] ?? "Profile loaded";
        email = data['email'];
        phone = data['phone']?.toString();
        address = data['address'];
        name = data['name'];
        point = data['point']?.toString();
        position = data['position']?.toString();
        discount = data['discount']?.toString();
        photo = data['photo'];
      } else {
        message = data['message'] ?? "Failed to load profile";
      }
    } catch (e) {
      message = "Network error $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(XFile image) async {
    message = "";
    isLoading = true;
    notifyListeners();
    try {
      id ??= await dataProvider.readSecureData('id');
      if (id == null) {
        message = "No user ID found";
        return;
      }

      MultipartFile multipartFile;
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        multipartFile = MultipartFile.fromBytes(bytes, filename: image.name);
      } else {
        multipartFile = await MultipartFile.fromFile(image.path, filename: image.name);
      }

      FormData formData = FormData.fromMap({
        'id': id,
        'image': multipartFile,
      });

      var response = await _dio.post(
        ("$accounturl/upload-image"),
        data: formData,
      );

      final data = response.data;
      if (response.statusCode == 200) {
        message = "successfully updated";
        photo = data['photo'];
      } else {
        message = data['error'] ?? data['message'] ?? "Update failed";
      }
    } catch (e) {
      message = "Network error $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
