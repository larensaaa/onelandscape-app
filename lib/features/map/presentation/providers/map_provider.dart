import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MapProvider extends ChangeNotifier {
  final MapController mapController = MapController();

  // State Menggambar
  bool _isDrawing = false;
  final List<LatLng> _drawingPoints = [];

  // State untuk item yang dipilih
  dynamic _selectedItem;

  // Getters
  bool get isDrawing => _isDrawing;
  List<LatLng> get drawingPoints => _drawingPoints;
  dynamic get selectedItem => _selectedItem;

  void toggleDrawingMode() {
    _isDrawing = !_isDrawing;
    _drawingPoints.clear();
    _selectedItem = null;
    notifyListeners();
  }

  void addDrawingPoint(LatLng point) {
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

  Future<void> saveArea({
    required BuildContext context,
    required Function(String, List<LatLng>)? onAreaSubmit,
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
        mapController.move(LatLng(result.first.latitude, result.first.longitude), 15.0);
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
    mapController.move(LatLng(position.latitude, position.longitude), 15.0);
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