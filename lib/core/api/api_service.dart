import 'package:dio/dio.dart';
import 'package:onelandscape/core/storage/secure_storage.dart'; 

class ApiService {
  final Dio _dio;
  final SecureStorageService _storage = SecureStorageService();

// 
  ApiService._()
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'https://onelandscapekalsel.vps-poliban.my.id/api',
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        ) {

    // Tambahkan Interceptor untuk otomatisasi token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.readToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            await _storage.deleteToken();
            
          }
          return handler.next(e);
        },
      ),
    );
  }

  // Singleton Pattern
  static final ApiService _instance = ApiService._();

  /// Mendapatkan instance Dio yang sudah dikonfigurasi.
  static Dio get dio => _instance._dio;
}