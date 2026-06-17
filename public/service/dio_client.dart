import 'package:dio/dio.dart';
import 'package:project2/herbalife/public/constants/constants.dart';
import 'package:project2/herbalife/public/provider/data_provider.dart';

class DioClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: accounturl,
      contentType: 'application/json',
    ),
  );

  static Dio get instance {
    _dio.interceptors.clear();
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Automatically attach access token to every request
          final storage = SecureStorageProvider();
          final token = await storage.readSecureData('token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // If 401 — token expired, try to refresh
          if (error.response?.statusCode == 401) {
            final storage = SecureStorageProvider();
            final refreshToken = await storage.readSecureData('refreshToken');

            if (refreshToken != null) {
              try {
                // Call refresh endpoint
                final refreshDio = Dio(); // separate dio to avoid infinite loop
                final response = await refreshDio.post(
                  '$accounturl/refresh',
                  data: {'token': refreshToken},
                );

                if (response.statusCode == 200) {
                  final newAccessToken = response.data['accessToken'];

                  // Save new access token
                  await storage.writeSecureData('token', newAccessToken);

                  // Retry the original request with new token
                  error.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                  final retryResponse = await _dio.fetch(error.requestOptions);
                  return handler.resolve(retryResponse);
                }
              } catch (e) {
                // Refresh failed — user needs to login again
                await storage.clearSecureData();
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
    return _dio;
  }
}