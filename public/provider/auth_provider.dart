import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // Replaced http with dio
import 'package:project2/herbalife/public/provider/data_provider.dart';
import 'package:project2/herbalife/public/constants/constants.dart';

class Authprovider extends ChangeNotifier {
  // Initialize Dio instance
  final Dio _dio = Dio();
  final SecureStorageProvider dataProvider = SecureStorageProvider();

  String? message;
  bool isLoading = false;
  String? userToken;
  String? refreshToken;
  String? userId;
  String? id;
  File? image;
  double totalPoints = 0;

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

      // Dio automatically decodes JSON, so no need for json.decode()
      final data = response.data;

      if (response.statusCode == 200) {
        message = data['message'];
        userToken = data['token'];
        refreshToken = data['refreshtoken'];
        userId = data['userid']?.toString();
        print("userid$userId");
        id = data['id']?.toString();
      } else {
        message = data['message'];
        userToken = null;
      }
    } on DioException catch (e) {
      // Dio catches non-200 status codes as exceptions by default
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
      File image,
      ) async {
    message = "";
    isLoading = true;
    notifyListeners();

    try {
      // Dio uses FormData for multipart/form-data requests
      String fileName = image.path.split('/').last;
      FormData formData = FormData.fromMap({
        'name': name,
        'address': address,
        'phone': phone,
        'email': email,
        'image': await MultipartFile.fromFile(image.path, filename: fileName),
      });

      final response = await _dio.post(
        "$accounturl/register",
        data: formData,
      );

      final data = response.data;

      if (response.statusCode == 200) {
        message = "successfully";
        userId = data['userid']?.toString();
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

  Future<void> register2(int userid, int password, int userids) async {
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
        message = data['message'];
        userId = data['userids']?.toString();
      } else {
        message = data['message'];
      }
    } on DioException catch (e) {
      message = e.response?.data['message'] ?? "Network failed";
    } catch (e) {
      message = "Network failed";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


}