import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:project2/herbalife/public/constants/constants.dart';
import 'package:project2/herbalife/public/service/dio_client.dart';
import 'package:project2/herbalife/public/provider/data_provider.dart';

class InfoProvider extends ChangeNotifier {
  final Dio _dio = DioClient.instance;
  final dataProvider = SecureStorageProvider();
  bool _isLoading = false;
  String? _message;
  List<dynamic> _users = [];

  bool get isLoading => _isLoading;
  String? get message => _message;
  List<dynamic> get users => _users;

  Future<void> updatePoints({required double pointChange}) async {
    _isLoading = true;
    _message = null;
    notifyListeners();

    try {
      String? infoId = await dataProvider.readSecureData('infoId');
      final response = await _dio.patch(
        '$accounturl/updatepoints',
        data: {
          'userids': infoId,
          'pointChange': pointChange,
        },
      );

      if (response.statusCode == 200) {
        _message = response.data['message'];
      } else {
        _message = response.data['error'] ?? 'Failed to update points';
      }
    } on DioException catch (e) {
      _message = e.response?.data['error'] ?? 'Connection error';
      debugPrint("Update points failed: $e");
    } catch (e) {
      _message = 'An unexpected error occurred';
      debugPrint("Unexpected error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getAllUsers() async {
    _isLoading = true;
    _message = null;
    notifyListeners();

    try {
      final response = await _dio.get('$accounturl/users');

      if (response.statusCode == 200) {
        _users = response.data;
        debugPrint("Users id : ${_users.map((user) => user['id'])}");
        _message = "Users fetched successfully";
      } else {
        _message = 'Failed to fetch users';
      }
    } on DioException catch (e) {
      _message = e.response?.data['error'] ?? 'Connection error';
      debugPrint("Get all users failed: $e");
    } catch (e) {
      _message = 'An unexpected error occurred';
      debugPrint("Unexpected error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateRoleToAdmin(int id) async {
    _isLoading = true;
    _message = null;
    notifyListeners();

    try {
      final response = await _dio.patch(
        '$accounturl/update-role-admin',
        data: {'id': id},
      );

      if (response.statusCode == 200) {
        _message = response.data['message'];
        await getAllUsers(); // Refresh list after update
      } else {
        _message = response.data['error'] ?? 'Failed to update role';
      }
    } on DioException catch (e) {
      _message = e.response?.data['error'] ?? 'Connection error';
      debugPrint("Update role to admin failed: $e");
    } catch (e) {
      _message = 'An unexpected error occurred';
      debugPrint("Unexpected error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateRoleToUser(int id) async {
    _isLoading = true;
    _message = null;
    notifyListeners();

    try {
      final response = await _dio.patch(
        '$accounturl/update-role-user',
        data: {'id': id},
      );

      if (response.statusCode == 200) {
        _message = response.data['message'];
        await getAllUsers(); // Refresh list after update
      } else {
        _message = response.data['error'] ?? 'Failed to update role';
      }
    } on DioException catch (e) {
      _message = e.response?.data['error'] ?? 'Connection error';
      debugPrint("Update role to user failed: $e");
    } catch (e) {
      _message = 'An unexpected error occurred';
      debugPrint("Unexpected error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
