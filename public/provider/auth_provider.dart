import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project2/herbalife/public/provider/data_provider.dart';
import 'package:project2/herbalife/public/constants/constants.dart';

class Authprovider extends ChangeNotifier {
  final Dio _dio = Dio();
  final SecureStorageProvider dataProvider = SecureStorageProvider();

  String? message;
  bool isLoading = false;
  String? userToken;
  String? refreshToken;
  String? userId; // Member ID
  String? id;     // Users Table PK
  String? infoId; // Infos Table PK
  XFile? image;

  String get isUserid => userId ?? "No id";

  Future<void> login(String userid, String password) async {
    message = "";
    isLoading = true;
    notifyListeners();

    try {
      final response = await _dio.post(
        "$accounturl/login",
        data: {'userid': userid, 'password': password},
      );

      final data = response.data;

      if (response.statusCode == 200) {
        message = data['message'];
        userToken = data['token'];
        refreshToken = data['refreshToken'] ?? data['refreshtoken'];
        infoId = data['infoId']?.toString();

        // Save to secure storage
        if (userToken != null) await dataProvider.writeSecureData('token', userToken!);
        if (infoId != null) await dataProvider.writeSecureData('infoId', infoId!);
        
      } else {
        message = data['message'] ?? "Login failed";
        userToken = null;
      }
    } on DioException catch (e) {
      message = e.response?.data['message'] ?? "Login failed: ${e.message}";
    } catch (e) {
      message = "Login failed: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(
    String name,
    String address,
    String phone,
    String email,
    XFile image,
  ) async {
    message = "";
    isLoading = true;
    notifyListeners();

    try {
      MultipartFile multipartFile;
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        multipartFile = MultipartFile.fromBytes(bytes, filename: image.name);
      } else {
        multipartFile = await MultipartFile.fromFile(image.path, filename: image.name);
      }

      FormData formData = FormData.fromMap({
        'name': name,
        'address': address,
        'phone': phone,
        'email': email,
        'image': multipartFile,
      });

      final response = await _dio.post(
        "$accounturl/register",
        data: formData,
      );

      final data = response.data;

      if (response.statusCode == 200) {
        message = "successfully";
        userId = data['userId']?.toString() ?? data['userid']?.toString();
      } else {
        message = data['error'] ?? data['message'] ?? "Registration failed";
      }
    } on DioException catch (e) {
      message = e.response?.data['error'] ?? e.message;
    } catch (e) {
      message = "Network failed: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register2(String userid, String password, String userids) async {
    message = "";
    isLoading = true;
    notifyListeners();

    try {
      final response = await _dio.post(
        "$accounturl/register2",
        data: {
          'userid': userid,
          'password': password,
          'userids': userids,
        },
      );

      final data = response.data;
      if (response.statusCode == 200) {
        message = data['message'] ?? "Registered successfully";
      } else {
        message = data['message'] ?? "Registration failed";
      }
    } on DioException catch (e) {
      message = e.response?.data['message'] ?? "Network error: ${e.message}";
    } catch (e) {
      message = "Network failed: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
