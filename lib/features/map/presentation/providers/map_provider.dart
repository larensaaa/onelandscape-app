import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:onelandscape/features/category/data/models/category_model.dart';
import 'package:onelandscape/features/category/data/repositories/category_repository.dart';
import '../../data/models/map_model.dart';
import '../../data/repositories/map_repository.dart';

class MapProvider extends ChangeNotifier {
  final MapRepository _mapRepository = MapRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();
  final MapController mapController = MapController();

  List<LocationData> _locations = [];
  List<AreaData> _areas = [];
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isDrawing = false;
  final List<latlong.LatLng> _drawingPoints = [];
  dynamic _selectedItem;

  List<LocationData> get locations => _locations;
  List<AreaData> get areas => _areas;
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isDrawing => _isDrawing;
  List<latlong.LatLng> get drawingPoints => _drawingPoints;
  dynamic get selectedItem => _selectedItem;

  Future<void> fetchMapData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _mapRepository.getLocations(),
        _mapRepository.getAreas(),
        _categoryRepository.getCategories(),
      ]);
      _locations = results[0] as List<LocationData>;
      _areas = results[1] as List<AreaData>;
      _categories = results[2] as List<Category>;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

 

  Future<void> addLocation(LocationData location) async {
    try {
      await _mapRepository.createLocation(location);
      await fetchMapData();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateLocation(int id, LocationData location) async {
    try {
      await _mapRepository.updateLocation(id, location);
      await fetchMapData();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteLocation(int id) async {
    try {
      await _mapRepository.deleteLocation(id);
      await fetchMapData();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> addArea(AreaData area) async {
    try {
      await _mapRepository.createArea(area);
      await fetchMapData();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateArea(int id, AreaData area) async {
    try {
      await _mapRepository.updateArea(id, area);
      await fetchMapData();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteArea(int id) async {
    try {
      await _mapRepository.deleteArea(id);
      await fetchMapData();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void toggleDrawingMode() {
    _isDrawing = !_isDrawing;
    _drawingPoints.clear();
    _selectedItem = null;
    notifyListeners();
  }

  void addDrawingPoint(latlong.LatLng point) {
    if (_isDrawing) {
      _drawingPoints.add(point);
      notifyListeners();
    }
  }

  void selectItem(dynamic item) {
    _selectedItem = item;
    notifyListeners();
  }

  void deselectItem() {
    _selectedItem = null;
    notifyListeners();
  }

  Future<void> submitDrawnArea(BuildContext context) async {
    if (_drawingPoints.length < 3) return;

    final areaName = await _showNameInputDialog(context);
    if (areaName != null && areaName.isNotEmpty) {
      final newArea = AreaData(
        id: 0,
        name: areaName,
        description: '',
        coordinates: List.from(_drawingPoints),
        color: Colors.green,
      );

      await addArea(newArea);

      _isDrawing = false;
      _drawingPoints.clear();
      notifyListeners();
    }
  }

  void moveCameraToArea(AreaData area) {
    if (area.coordinates.isNotEmpty) {
      final bounds = LatLngBounds.fromPoints(area.coordinates);
      mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(40.0)),
      );
    }
  }

  Future<void> searchAndMove(BuildContext context, String query) async {
    if (query.isEmpty) return;
    FocusScope.of(context).unfocus();
    try {
      final result = await locationFromAddress(query);
      if (result.isNotEmpty) {
        mapController.move(
          latlong.LatLng(result.first.latitude, result.first.longitude),
          15.0,
        );
      }
    } catch (e) {
      debugPrint("Error searching location: $e");
    }
  }

  Future<void> determinePositionAndMove(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled && context.mounted) {
      _showSnackBar(context, 'Layanan lokasi tidak aktif.');
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied && context.mounted) {
        _showSnackBar(context, 'Izin lokasi ditolak.');
        return;
      }
    }
    if (permission == LocationPermission.deniedForever && context.mounted) {
      _showSnackBar(context, 'Izin lokasi ditolak permanen.');
      return;
    }
    final position = await Geolocator.getCurrentPosition();
    mapController.move(
      latlong.LatLng(position.latitude, position.longitude),
      15.0,
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<String?> _showNameInputDialog(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Masukkan Nama Area"),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: "Area Baru"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }
}
