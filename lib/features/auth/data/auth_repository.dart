import 'package:dio/dio.dart';
import 'package:onelandscape/core/api/api_service.dart';
import 'package:onelandscape/core/storage/secure_storage.dart';
import 'package:onelandscape/features/auth/data/models/user_model.dart';

class AuthRepository {
  final Dio _dio = ApiService.dio;
  final SecureStorageService _storage = SecureStorageService();

  /// Fungsi untuk login
  Future<User> login({required String email, required String password}) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      final token = response.data['authorisation']['token'];
      await _storage.saveToken(token);
      return User.fromJson(response.data['user']);
    } on DioException catch (e) {

      throw Exception(
        'Gagal login: ${e.response?.data['message'] ?? e.message}',
      );
    }
  }

  /// Fungsi untuk register
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/register',
        data: {'name': name, 'email': email, 'password': password},
      );

      print('--- DEBUG REGISTER RESPONSE ---');
      print(response.data);
      print('--- END DEBUG ---');

      
     
      return User.fromJson(response.data['user']);
    } on DioException catch (e) {
      throw Exception(
        'Gagal register: ${e.response?.data['message'] ?? e.message}',
      );
    }
  }

  /// Fungsi untuk mendapatkan profil user yang sedang login
  Future<User> getProfile() async {
    try {
      final response = await _dio.get('/me');
      return User.fromJson(response.data['user']);
    } on DioException catch (e) {
      throw Exception('Gagal mendapatkan profil: ${e.message}');
    }
  }

  /// Fungsi untuk logout
  Future<void> logout() async {
    try {
      await _dio.post('/logout');
    } finally {
      // Selalu hapus token dari perangkat, meskipun request API gagal
      await _storage.deleteToken();
    }
  }
}
