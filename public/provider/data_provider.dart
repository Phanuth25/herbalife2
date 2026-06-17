import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageProvider extends ChangeNotifier {
  // Initialize the storage instance
  final _storage = const FlutterSecureStorage();

  // Write data
  Future<void> writeSecureData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // Read data
  Future<String?> readSecureData(String key) async {
    return await _storage.read(key: key);
  }

  // Delete specific key
  Future<void> deleteSecureData(String key) async {
    await _storage.delete(key: key);
  }
  // Clear all data
  Future<void> clearSecureData() async {
    await _storage.deleteAll();
  }
}
