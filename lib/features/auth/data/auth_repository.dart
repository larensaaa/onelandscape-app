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

      // -- PRINT 1: Lihat data mentah dari /login --
      print('DEBUG REPO (login): Raw user data from /login -> ${response.data['user']}');

      final token = response.data['authorisation']['token'];
      await _storage.saveToken(token);
      return User.fromJson(response.data['user']);
    } on DioException catch (e) {
      throw Exception('Gagal login: ${e.response?.data['message'] ?? e.message}');
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
      
      // Token handling yang benar untuk register (jika API mengembalikannya)
      final tokenData = response.data['authorisation'];
      if (tokenData != null && tokenData['token'] != null) {
        await _storage.saveToken(tokenData['token']);
      }
      
      return User.fromJson(response.data['user']);
    } on DioException catch (e) {
      throw Exception('Gagal register: ${e.response?.data['message'] ?? e.message}');
    }
  }

  /// Fungsi untuk mendapatkan profil user yang sedang login
  Future<User> getProfile() async {
    try {
      final response = await _dio.get('/me');
      
      // -- PRINT 2: Lihat data mentah dari /me --
      print('DEBUG REPO (getProfile): Raw user data from /me -> ${response.data['user']}');
      
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
      await _storage.deleteToken();
    }
  }
}