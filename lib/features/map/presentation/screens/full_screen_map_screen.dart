import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:provider/provider.dart';
import '../../data/models/map_model.dart';
import '../providers/map_provider.dart';
import '../widgets/reusable_map_widget.dart';

class FullScreenMapScreen extends StatefulWidget {
  const FullScreenMapScreen({super.key});

  @override
  State<FullScreenMapScreen> createState() => _FullScreenMapScreenState();
}

class _FullScreenMapScreenState extends State<FullScreenMapScreen> {
  final List<LocationData> _locations = [];
  final List<AreaData> _areas = [];
  latlong.LatLng? _tappedPoint;
  late MapProvider _mapProvider;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _mapProvider = MapProvider();
    _loadInitialData();
  }

  void _loadInitialData() {
    _locations.add(LocationData(id: 1, name: 'Politeknik Negeri Banjarmasin', position: const latlong.LatLng(-3.296332, 114.582371), icon: Icons.school, color: Colors.blue.shade700));
    _locations.add(LocationData(id: 2, name: 'Duta Mall Banjarmasin', position: const latlong.LatLng(-3.322712, 114.602978), icon: Icons.store, color: Colors.red.shade700));
    _areas.add(AreaData(id: 1, name: 'Area Poliban', coordinates: const [latlong.LatLng(-3.297022, 114.581007), latlong.LatLng(-3.296186, 114.581442), latlong.LatLng(-3.295806, 114.581378), latlong.LatLng(-3.294864, 114.582134), latlong.LatLng(-3.294671, 114.582080), latlong.LatLng(-3.295571, 114.583019), latlong.LatLng(-3.295854, 114.583223), latlong.LatLng(-3.297456, 114.581447), latlong.LatLng(-3.297022, 114.581007)], color: Colors.blue));
    setState(() {});
  }

  void _handleMapTap(latlong.LatLng point) {
    setState(() => _tappedPoint = point);
    _showAddLocationDialog(point);
  }

  void _handleAreaSubmit(String name, List<latlong.LatLng> coordinates) {
    setState(() {
      final newId = _areas.isEmpty ? 1 : _areas.map((a) => a.id).reduce((a, b) => a > b ? a : b) + 1;
      _areas.add(AreaData(id: newId, name: name, coordinates: coordinates, color: Colors.green));
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Area "$name" berhasil disimpan!')));
  }

  void _handleLocationLongPress(LocationData location) {
    _showEditDeleteOptions(item: location);
  }

  void _handleAreaLongPress(AreaData area) {
    _mapProvider.moveCameraToArea(area);
    _showEditDeleteOptions(item: area);
  }

  void _showEditDeleteOptions({required dynamic item}) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                if (item is LocationData) {
                  _showAddLocationDialog(item.position, existingLocation: item);
                } else if (item is AreaData) {
                  _showEditAreaDialog(item);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Hapus'),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(item);
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditAreaDialog(AreaData area) {
    final controller = TextEditingController(text: area.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Nama Area"),
        content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(labelText: "Nama Area")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          TextButton(
            child: const Text("Simpan"),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final index = _areas.indexWhere((a) => a.id == area.id);
                if (index != -1) {
                  setState(() => _areas[index] = AreaData(id: area.id, name: controller.text, coordinates: area.coordinates, color: area.color));
                }
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(dynamic item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus "${item.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            onPressed: () {
              setState(() {
                if (item is LocationData) {
                  _locations.removeWhere((loc) => loc.id == item.id);
                } else if (item is AreaData) {
                  _areas.removeWhere((a) => a.id == item.id);
                }
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showAddLocationDialog(latlong.LatLng point, {LocationData? existingLocation}) {
    final titleController = TextEditingController(text: existingLocation?.name ?? '');
    final descController = TextEditingController(text: existingLocation?.description ?? '');
    String selectedCategory = 'Tempat Wisata';
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(existingLocation == null ? "Tambah Lokasi Baru" : "Edit Lokasi"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Koordinat: ${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}"),
                    const SizedBox(height: 12),
                    TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Judul')),
                    const SizedBox(height: 8),
                    TextField(controller: descController, decoration: const InputDecoration(labelText: 'Keterangan')),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: selectedCategory,
                      isExpanded: true,
                      items: ['Tempat Wisata', 'Restoran', 'Kantor Polisi', 'Rumah Sakit', 'Lainnya']
                          .map((String value) => DropdownMenuItem<String>(value: value, child: Text(value)))
                          .toList(),
                      onChanged: (String? newValue) => setDialogState(() => selectedCategory = newValue!),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Batal")),
                TextButton(
                  child: const Text("Simpan"),
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      setState(() {
                        if (existingLocation != null) {
                          final index = _locations.indexWhere((loc) => loc.id == existingLocation.id);
                          if (index != -1) {
                            _locations[index] = LocationData(id: existingLocation.id, name: titleController.text, description: descController.text, position: existingLocation.position);
                          }
                        } else {
                          final newId = _locations.isEmpty ? 1 : _locations.map((l) => l.id).reduce((a, b) => a > b ? a : b) + 1;
                          _locations.add(LocationData(id: newId, name: titleController.text, description: descController.text, position: point));
                          _tappedPoint = null;
                        }
                      });
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _mapProvider,
      child: Consumer<MapProvider>(
        builder: (context, mapProvider, child) {
          return Scaffold(
            body: Stack(
              children: [
                ReusableMapWidget(
                  locations: _locations,
                  areas: _areas,
                  selectedLocationMarker: _tappedPoint,
                  onMapTap: _handleMapTap,
                  onAreaSubmit: _handleAreaSubmit,
                  onLocationLongPress: _handleLocationLongPress,
                  onAreaLongPress: _handleAreaLongPress,
                ),
                _buildDetailsSheet(mapProvider),
                Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.25 + 16,
                  right: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton(onPressed: () => mapProvider.determinePositionAndMove(context), tooltip: 'Cari Lokasi Saya', heroTag: 'myLocationButton', child: const Icon(Icons.my_location)),
                      const SizedBox(height: 10),
                      FloatingActionButton(onPressed: mapProvider.toggleDrawingMode, tooltip: mapProvider.isDrawing ? 'Batal Menggambar' : 'Gambar Area', heroTag: 'drawButton', backgroundColor: mapProvider.isDrawing ? Colors.red : Theme.of(context).colorScheme.secondary, child: Icon(mapProvider.isDrawing ? Icons.close : Icons.edit)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailsSheet(MapProvider provider) {
    return DraggableScrollableSheet(
      initialChildSize: 0.25,
      minChildSize: 0.15,
      maxChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(24)), boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 10, offset: const Offset(0, -2))]),
          child: ListView(
            controller: scrollController,
            children: [
              Center(child: Container(height: 5, width: 40, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(hintText: "Cari lokasi...", prefixIcon: const Icon(Icons.search), suffixIcon: IconButton(icon: const Icon(Icons.send), onPressed: () => provider.searchAndMove(context, _searchController.text)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none), fillColor: Colors.grey[200], filled: true, contentPadding: const EdgeInsets.symmetric(horizontal: 16)),
                onSubmitted: (value) => provider.searchAndMove(context, value),
              ),
              const SizedBox(height: 12),
              ..._locations.map((loc) {
                return ListTile(
                  leading: Icon(loc.icon, color: loc.color),
                  title: Text(loc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text("Kalimantan Selatan"),
                  onTap: () => provider.mapController.move(loc.position, 16.0),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}