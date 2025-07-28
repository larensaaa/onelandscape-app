import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as latlong;
import '../../data/models/map_model.dart';

class MapProvider extends ChangeNotifier {
  final MapController mapController = MapController();
  bool _isDrawing = false;
  final List<latlong.LatLng> _drawingPoints = [];
  dynamic _selectedItem;

  bool get isDrawing => _isDrawing;
  List<latlong.LatLng> get drawingPoints => _drawingPoints;
  dynamic get selectedItem => _selectedItem;

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

  void moveCameraToArea(AreaData area) {
    if (area.coordinates.isNotEmpty) {
      final bounds = LatLngBounds.fromPoints(area.coordinates);
      mapController.fitCamera(CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(40.0),
      ));
    }
  }

  Future<void> saveArea({
    required BuildContext context,
    required Function(String, List<latlong.LatLng>)? onAreaSubmit,
  }) async {
    if (_drawingPoints.length < 3) return;
    if (onAreaSubmit == null) return;
    final areaName = await _showNameInputDialog(context);
    if (areaName != null && areaName.isNotEmpty) {
      onAreaSubmit(areaName, List.from(_drawingPoints));
      _isDrawing = false;
      _drawingPoints.clear();
      notifyListeners();
    }
  }

  Future<void> searchAndMove(BuildContext context, String query) async {
    if (query.isEmpty) return;
    FocusScope.of(context).unfocus();
    try {
      final result = await locationFromAddress(query);
      if (result.isNotEmpty) {
        mapController.move(latlong.LatLng(result.first.latitude, result.first.longitude), 15.0);
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
    mapController.move(latlong.LatLng(position.latitude, position.longitude), 15.0);
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<String?> _showNameInputDialog(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Masukkan Nama Area"),
        content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(hintText: "Area Baru")),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.of(context).pop(controller.text), child: const Text("Simpan")),
        ],
      ),
    );
  }
}