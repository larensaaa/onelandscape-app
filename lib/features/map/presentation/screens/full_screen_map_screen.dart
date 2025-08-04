import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:provider/provider.dart';
import 'package:onelandscape/features/auth/presentation/providers/auth_provider.dart';
import '../../data/models/map_model.dart';
import '../providers/map_provider.dart';
import '../widgets/reusable_map_widget.dart';

class FullScreenMapScreen extends StatefulWidget {
  const FullScreenMapScreen({super.key});

  @override
  State<FullScreenMapScreen> createState() => _FullScreenMapScreenState();
}

class _FullScreenMapScreenState extends State<FullScreenMapScreen> {
  late MapProvider _mapProvider;
  final TextEditingController _searchController = TextEditingController();
  latlong.LatLng? _tappedPoint;

  @override
  void initState() {
    super.initState();
    _mapProvider = MapProvider();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapProvider.fetchMapData();
    });
  }

  // --- HANDLER UNTUK AKSI DARI UI ---

  void _handleMapTap(latlong.LatLng point) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userRole = authProvider.user?.userLevel?.name ?? 'user';
    if (!['admin', 'supervisor', 'user'].contains(userRole)) return;
    
    setState(() => _tappedPoint = point);
    _showAddLocationDialog(point);
  }

  // --- FUNGSI _handleAreaSubmit SUDAH DIHAPUS ---
  // Logikanya sekarang ada di dalam MapProvider.submitDrawnArea

  void _handleLocationLongPress(LocationData location) {
    _showEditDeleteOptions(item: location);
  }

  void _handleAreaLongPress(AreaData area) {
    _mapProvider.moveCameraToArea(area);
    _showEditDeleteOptions(item: area);
  }

  // --- WIDGET DIALOG DAN MENU ---
  void _showEditDeleteOptions({required dynamic item}) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userRole = authProvider.user?.userLevel?.name ?? 'user';

    if (item is AreaData && !['admin', 'supervisor'].contains(userRole)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hanya admin atau supervisor yang bisa mengubah area.')));
      return;
    }
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
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
      ),
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
                final updatedArea = AreaData(
                  id: area.id,
                  name: controller.text,
                  description: area.description,
                  coordinates: area.coordinates,
                  color: area.color,
                );
                _mapProvider.updateArea(area.id, updatedArea);
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
              if (item is LocationData) {
                _mapProvider.deleteLocation(item.id);
              } else if (item is AreaData) {
                _mapProvider.deleteArea(item.id);
              }
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
    String? selectedCategory;

    final categories = _mapProvider.categories;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
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
                  hint: const Text('Pilih Kategori'),
                  items: categories // <-- Gunakan variabel 'categories'
                      .map((category) => DropdownMenuItem<String>(value: category.name, child: Text(category.name)))
                      .toList(),
                  onChanged: (String? newValue) => setDialogState(() => selectedCategory = newValue),
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
                  if (existingLocation != null) {
                    final updatedLocation = LocationData(
                      id: existingLocation.id,
                      name: titleController.text,
                      description: descController.text,
                      position: existingLocation.position,
                      icon: existingLocation.icon,
                      color: existingLocation.color,
                    );
                    _mapProvider.updateLocation(existingLocation.id, updatedLocation);
                  } else {
                    final newLocation = LocationData(
                      id: 0,
                      name: titleController.text,
                      description: descController.text,
                      position: point,
                      icon: Icons.location_on,
                      color: Colors.red,
                    );
                    _mapProvider.addLocation(newLocation);
                    setState(() => _tappedPoint = null);
                  }
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userRole = authProvider.user?.userLevel?.name ?? 'user';

    return ChangeNotifierProvider.value(
      value: _mapProvider,
      child: Consumer<MapProvider>(
        builder: (context, mapProvider, child) {
          final bool canDrawArea = ['admin', 'supervisor'].contains(userRole);

          return Scaffold(
            body: Stack(
              children: [
                if (mapProvider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (mapProvider.errorMessage != null)
                  Center(child: Text(mapProvider.errorMessage!))
                else
                  ReusableMapWidget(
                    locations: mapProvider.locations,
                    areas: mapProvider.areas,
                    selectedLocationMarker: _tappedPoint,
                    onMapTap: _handleMapTap,
                   
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
                      if (canDrawArea) ...[
                        const SizedBox(height: 10),
                        FloatingActionButton(onPressed: mapProvider.toggleDrawingMode, tooltip: 'Gambar Area', heroTag: 'drawButton', backgroundColor: mapProvider.isDrawing ? Colors.red : Theme.of(context).colorScheme.secondary, child: Icon(mapProvider.isDrawing ? Icons.close : Icons.edit)),
                      ],
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
              ...provider.locations.map((loc) {
                return ListTile(
                  leading: Icon(loc.icon, color: loc.color),
                  title: Text(loc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(loc.description),
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