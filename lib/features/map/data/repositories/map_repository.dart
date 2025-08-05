import 'package:dio/dio.dart';
import 'package:onelandscape/core/api/api_service.dart';
import 'package:onelandscape/features/map/data/models/map_model.dart';

class MapRepository {
  final Dio _dio = ApiService.dio;

  Future<List<LocationData>> getLocations() async {
    try {
      final response = await _dio.get('/locations');
      
      return (response.data as List).map((item) => LocationData.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Gagal memuat data lokasi');
    }
  }

  Future<List<AreaData>> getAreas() async {
    try {
      final response = await _dio.get('/areas');
       print('--- DEBUG: RAW AREAS RESPONSE ---');
      print(response.data);
      print('--- END DEBUG ---');

      return (response.data as List).map((item) => AreaData.fromJson(item)).toList();
    } catch (e) {
       print('--- DEBUG: ERROR GETTING AREAS ---');
      print(e);
      print('--- END DEBUG ---');
      throw Exception('Gagal memuat data area');
    }
  }

 // features/map/data/repositories/map_repository.dart

  Future<void> createLocation(LocationData location) async {
    try {
      await _dio.post('/locations', data: location.toJson());
    } on DioException catch (e) {
      print('--- DEBUG: 422 VALIDATION ERROR ---');
      if (e.response != null) {
        print(e.response!.data);
      }
      print('--- END DEBUG ---');
      // ----------------------------------------------------
      throw Exception('Gagal membuat lokasi baru: ${e.response?.data['message'] ?? e.message}');
    }
  }
  
  Future<void> updateLocation(int id, LocationData location) async {
    try {
      await _dio.put('/locations/$id', data: location.toJson());
    } catch (e) {
      throw Exception('Gagal memperbarui lokasi');
    }
  }
  
  Future<void> deleteLocation(int id) async {
    try {
      await _dio.delete('/locations/$id');
    } catch (e) {
      throw Exception('Gagal menghapus lokasi');
    }
  }
  
  Future<void> createArea(AreaData area) async {
    try {
      await _dio.post('/areas', data: area.toJson());
    } catch (e) {
      throw Exception('Gagal membuat area baru');
    }
  }

  Future<void> updateArea(int id, AreaData area) async {
    try {
      await _dio.put('/areas/$id', data: {
        'name': area.name,
        'description': area.description
      });
    } catch (e) {
      throw Exception('Gagal memperbarui area');
    }
  }

  Future<void> deleteArea(int id) async {
    try {
      await _dio.delete('/areas/$id');
    } catch (e) {
      throw Exception('Gagal menghapus area');
    }
  }
}