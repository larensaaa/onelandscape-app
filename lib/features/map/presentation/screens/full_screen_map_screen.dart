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
    
    // Mengambil data peta setelah frame pertama selesai di-build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapProvider.fetchMapData();
    });
  }
  
  // Helper untuk mendapatkan peran pengguna dengan aman.
  String _getUserRole() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final role = authProvider.user?.role ?? '';
    print('DEBUG _getUserRole: Role -> "$role"');
    return role;
  }


  void _handleMapTap(latlong.LatLng point) {
    final userRole = _getUserRole();
    
    print('DEBUG _handleMapTap: User role -> "$userRole"');
    
    // ADMIN tidak boleh menambah lokasi
    if (userRole == 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admin hanya dapat melihat data, tidak dapat menambah lokasi.'),
          backgroundColor: Colors.orange,
        )
      );
      return;
    }
    
    // USER dan SUPERVISOR boleh menambah lokasi
    if (['user', 'supervisor'].contains(userRole)) {
      setState(() => _tappedPoint = point);
      _showAddLocationDialog(point);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda tidak memiliki hak akses untuk menambah lokasi.'),
          backgroundColor: Colors.red,
        )
      );
    }
  }

  void _handleLocationLongPress(LocationData location) {
    _showEditDeleteOptions(item: location);
  }

  void _handleAreaLongPress(AreaData area) {
    _mapProvider.moveCameraToArea(area);
    _showEditDeleteOptions(item: area);
  }

  void _showEditDeleteOptions({required dynamic item}) {
    final userRole = _getUserRole();
    
    print('DEBUG _showEditDeleteOptions: User role -> "$userRole", Item type -> ${item.runtimeType}');

    // ADMIN hanya bisa melihat (popup info saja)
    if (userRole == 'admin') {
      _mapProvider.selectItem(item); // Tampilkan popup info saja
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Info: ${item.name} - Admin hanya dapat melihat data.'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        )
      );
      return;
    }

    // USER tidak bisa edit/hapus AREA (polygon)
    if (item is AreaData && userRole == 'user') {
      _mapProvider.selectItem(item); // Tampilkan popup info saja
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User tidak dapat mengedit area/polygon.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        )
      );
      return;
    }
    
    // Jika sampai sini, berarti boleh edit/hapus:
    // - USER: untuk LocationData
    // - SUPERVISOR: untuk LocationData dan AreaData
    _showEditDeleteMenu(item);
  }

  void _showEditDeleteMenu(dynamic item) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.blue),
            title: Text('Info: ${item.name}'),
            subtitle: Text(item is LocationData ? 'Lokasi' : 'Area/Polygon'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.green),
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
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Hapus'),
            onTap: () {
              Navigator.pop(context);
              _confirmDelete(item);
            },
          ),
          ListTile(
            leading: const Icon(Icons.close, color: Colors.grey),
            title: const Text('Batal'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showSavePolygonDialog() {
    final drawingPoints = _mapProvider.drawingPoints; // Asumsi MapProvider punya getter ini
    
    if (drawingPoints.isEmpty || drawingPoints.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimal 3 titik diperlukan untuk membuat area/polygon.'),
          backgroundColor: Colors.orange,
        )
      );
      return;
    }
    
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.save, color: Colors.blue),
            SizedBox(width: 8),
            Text("Simpan \nArea/Polygon"),
          ],
        ),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Area dengan ${drawingPoints.length} titik akan disimpan",
                          style: const TextStyle(fontSize: 12, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Area',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Nama area wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descController, 
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi Area',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), 
            child: const Text("Batal")
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text("Simpan Area", style: TextStyle(color: Colors.white)),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final newArea = AreaData(
                  id: 0, // ID akan di-generate oleh backend
                  name: nameController.text,
                  description: descController.text.isEmpty ? 'Tidak ada deskripsi' : descController.text,
                  coordinates: List<latlong.LatLng>.from(drawingPoints),
                  color: Colors.blue.withOpacity(0.3),
                );
                
                _mapProvider.addArea(newArea);
                _mapProvider.toggleDrawingMode(); // Exit drawing mode
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Area/Polygon berhasil disimpan'),
                    backgroundColor: Colors.green,
                  )
                );
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  void _showEditAreaDialog(AreaData area) {
    final controller = TextEditingController(text: area.name);
    final descController = TextEditingController(text: area.description ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Area/Polygon"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller, 
              autofocus: true, 
              decoration: const InputDecoration(
                labelText: "Nama Area",
                border: OutlineInputBorder(),
              )
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController, 
              decoration: const InputDecoration(
                labelText: "Deskripsi Area",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Batal")
          ),
          ElevatedButton(
            child: const Text("Simpan"),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final updatedArea = AreaData(
                  id: area.id,
                  name: controller.text,
                  description: descController.text.trim().isEmpty ? area.description : descController.text.trim(),
                  coordinates: area.coordinates,
                  color: area.color,
                );
                _mapProvider.updateArea(area.id, updatedArea);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Area berhasil diupdate'))
                );
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text('Apakah Anda yakin ingin menghapus "${item.name}"?'),
            const SizedBox(height: 8),
            Text(
              item is LocationData ? 'Lokasi ini akan dihapus permanen.' : 'Area/Polygon ini akan dihapus permanen.',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('Batal')
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            onPressed: () {
              if (item is LocationData) {
                _mapProvider.deleteLocation(item.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lokasi berhasil dihapus'))
                );
              } else if (item is AreaData) {
                _mapProvider.deleteArea(item.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Area berhasil dihapus'))
                );
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showAddLocationDialog(latlong.LatLng point, {LocationData? existingLocation}) {
    final _formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: existingLocation?.name ?? '');
    final descController = TextEditingController(text: existingLocation?.description ?? '');
    int? selectedCategoryId = existingLocation?.categoryId;

    final categories = _mapProvider.categories;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(existingLocation == null ? Icons.add_location : Icons.edit_location),
              const SizedBox(width: 10),
              Text(existingLocation == null ? "Tambah Lokasi \nBaru" : "Edit Lokasi"),
            ],
          ),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Koordinat: ${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lokasi',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Nama lokasi wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descController, 
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: selectedCategoryId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: categories.map((category) => DropdownMenuItem<int>(
                      value: category.id, 
                      child: Text(category.name)
                    )).toList(),
                    onChanged: (int? newValue) => setDialogState(() => selectedCategoryId = newValue),
                    validator: (value) => value == null ? 'Kategori wajib dipilih' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), 
              child: const Text("Batal")
            ),
            ElevatedButton(
              child: Text(existingLocation == null ? "Tambah" : "Update"),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  if (existingLocation != null) {
                    final updatedLocation = LocationData(
                      id: existingLocation.id,
                      name: titleController.text,
                      description: descController.text,
                      position: existingLocation.position,
                      icon: existingLocation.icon,
                      color: existingLocation.color,
                      categoryId: selectedCategoryId,
                    );
                    _mapProvider.updateLocation(existingLocation.id, updatedLocation);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Lokasi berhasil diupdate'))
                    );
                  } else {
                    final newLocation = LocationData(
                      id: 0, 
                      name: titleController.text,
                      description: descController.text,
                      position: point,
                      icon: Icons.location_on, // Default icon
                      color: Colors.red, // Default color
                      categoryId: selectedCategoryId,
                    );
                    _mapProvider.addLocation(newLocation);
                    setState(() => _tappedPoint = null);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Lokasi berhasil ditambahkan'))
                    );
                  }
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dengarkan perubahan pada AuthProvider untuk mendapatkan role terbaru
    final authProvider = context.watch<AuthProvider>();
    final userRole = authProvider.user?.role ?? '';
    print('DEBUG BUILD: Peran Pengguna saat ini -> "$userRole"');
    
    final bool canDrawArea = userRole == 'supervisor';
   
    final roleColor = userRole == 'admin' ? Colors.blue : 
                     userRole == 'supervisor' ? Colors.green : Colors.orange;

    return ChangeNotifierProvider.value(
      value: _mapProvider,
      child: Consumer<MapProvider>(
        builder: (context, mapProvider, child) {
          return Scaffold(
            body: Stack(
              children: [
                if (mapProvider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (mapProvider.errorMessage != null)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${mapProvider.errorMessage!}',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => mapProvider.fetchMapData(),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  )
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
                
                // Role indicator
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: roleColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          userRole == 'admin' ? Icons.admin_panel_settings :
                          userRole == 'supervisor' ? Icons.supervisor_account : Icons.person,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          userRole.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Floating Action Buttons - Kanan
                Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.25 + 16,
                  right: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton(
                        onPressed: () => mapProvider.determinePositionAndMove(context), 
                        tooltip: 'Cari Lokasi Saya', 
                        heroTag: 'myLocationButton', 
                        child: const Icon(Icons.my_location)
                      ),
                      
                      // Tombol gambar area/polygon hanya muncul untuk SUPERVISOR
                      if (canDrawArea) ...[
                        const SizedBox(height: 10),
                        FloatingActionButton(
                          onPressed: mapProvider.toggleDrawingMode, 
                          tooltip: mapProvider.isDrawing ? 'Batal Gambar Area' : 'Gambar Area/Polygon', 
                          heroTag: 'drawButton', 
                          backgroundColor: mapProvider.isDrawing ? Colors.red : Colors.green,
                          child: Icon(
                            mapProvider.isDrawing ? Icons.close : Icons.edit_location_alt_outlined
                          )
                        ),
                      ],
                    ],
                  ),
                ),

                // Tombol Save Polygon - Kiri (hanya muncul saat sedang drawing)
                if (canDrawArea && mapProvider.isDrawing) 
                  Positioned(
                    bottom: MediaQuery.of(context).size.height * 0.25 + 16,
                    left: 16,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FloatingActionButton.extended(
                          onPressed: () => _showSavePolygonDialog(), 
                          tooltip: 'Simpan Area/Polygon', 
                          heroTag: 'savePolygonButton',
                          backgroundColor: Colors.blue,
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: const Text(
                            'Simpan Area',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 10),
                        
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
          decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)), 
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300, 
                blurRadius: 10, 
                offset: const Offset(0, -2)
              )
            ]
          ),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  height: 5, 
                  width: 40, 
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300, 
                    borderRadius: BorderRadius.circular(12)
                  )
                )
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Cari lokasi...", 
                  prefixIcon: const Icon(Icons.search), 
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send), 
                    onPressed: () => provider.searchAndMove(context, _searchController.text)
                  ), 
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30), 
                    borderSide: BorderSide.none
                  ), 
                  fillColor: Colors.grey[200], 
                  filled: true, 
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16)
                ),
                onSubmitted: (value) => provider.searchAndMove(context, value),
              ),
              const SizedBox(height: 12),
              
              // Header untuk daftar lokasi
              if (provider.locations.isNotEmpty) ...[
                Text(
                  'Daftar Lokasi (${provider.locations.length})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              
              // Menampilkan daftar lokasi
              ...provider.locations.map((loc) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: loc.color.withOpacity(0.2),
                      child: Icon(loc.icon, color: loc.color),
                    ),
                    title: Text(
                      loc.name, 
                      style: const TextStyle(fontWeight: FontWeight.bold)
                    ),
                    subtitle: Text(
                      loc.description.isEmpty ? 'Tidak ada deskripsi' : loc.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.location_on, color: Colors.grey),
                    // Tap untuk pindah kamera ke lokasi
                    onTap: () => provider.mapController.move(loc.position, 16.0),
                    // Long press akan ditangani oleh `onLocationLongPress` di ReusableMapWidget
                  ),
                );
              }).toList(),
              
              // Menampilkan daftar areas jika ada
              if (provider.areas.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Daftar Area/Polygon (${provider.areas.length})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ...provider.areas.map((area) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: area.color.withOpacity(0.2),
                        child: Icon(Icons.polyline, color: area.color),
                      ),
                      title: Text(
                        area.name, 
                        style: const TextStyle(fontWeight: FontWeight.bold)
                      ),
                      subtitle: Text(
                        area.description ?? 'Tidak ada deskripsi',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.map, color: Colors.grey),
                      onTap: () => provider.moveCameraToArea(area),
                    ),
                  );
                }).toList(),
              ],
            ],
          ),
        );
      },
    );
  }
}