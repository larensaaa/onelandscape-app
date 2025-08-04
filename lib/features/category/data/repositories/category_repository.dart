import 'package:dio/dio.dart';
import 'package:onelandscape/core/api/api_service.dart';
import 'package:onelandscape/features/category/data/models/category_model.dart';

class CategoryRepository {
  final Dio _dio = ApiService.dio;

  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get('/categories');
      return (response.data as List).map((item) => Category.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Gagal memuat kategori');
    }
  }
}