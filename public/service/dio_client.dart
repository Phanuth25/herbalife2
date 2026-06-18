import 'package:dio/dio.dart';
import 'package:project2/herbalife/public/constants/constants.dart';
import 'package:project2/herbalife/public/provider/data_provider.dart';

class DioClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: accounturl,
      contentType: 'application/json',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final storage = SecureStorageProvider();
          final token = await storage.readSecureData('token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final storage = SecureStorageProvider();
            // Check both common naming conventions
            String? refreshToken = await storage.readSecureData('refreshToken') ?? 
                                 await storage.readSecureData('refreshtoken');

            if (refreshToken != null) {
              try {
                final refreshDio = Dio(); 
                final response = await refreshDio.post(
                  '$accounturl/refresh',
                  data: {'token': refreshToken},
                );

                if (response.statusCode == 200) {
                  final newAccessToken = response.data['accessToken'] ?? response.data['token'];
                  if (newAccessToken != null) {
                    await storage.writeSecureData('token', newAccessToken);
                    error.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                    final retryResponse = await Dio(BaseOptions(baseUrl: accounturl)).fetch(error.requestOptions);
                    return handler.resolve(retryResponse);
                  }
                }
              } catch (e) {
                await storage.clearSecureData();
              }
            }
          }
          return handler.next(error);
        },
      ),
    );

  static Dio get instance => _dio;
}
