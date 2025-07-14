import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geocoding/geocoding.dart';

class FullScreenMapScreen extends StatefulWidget {
  const FullScreenMapScreen({super.key});

  @override
  State<FullScreenMapScreen> createState() => _FullScreenMapScreenState();
}

class _FullScreenMapScreenState extends State<FullScreenMapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  // State untuk Menggambar Poligon
  bool _isDrawing = false;
  final List<LatLng> _drawingPoints = [];
  final List<Polygon> _polygons = [];

  // Data Lokasi (Poliban & Duta Mall)
  final List<Map<String, dynamic>> locationItems = [
    {
      'name': 'Politeknik Negeri Banjarmasin',
      'location': const LatLng(-3.296332, 114.582371),
      'icon': Icons.school,
      'color': Colors.blue.shade700,
    },
    {
      'name': 'Duta Mall Banjarmasin',
      'location': const LatLng(-3.322712, 114.602978),
      'icon': Icons.store,
      'color': Colors.red.shade700,
    },
  ];

  // Koordinat Poligon Area Poliban
  final List<LatLng> polibanAreaPoints = [
    const LatLng(-3.297022, 114.581007),
    const LatLng(-3.296186, 114.581442),
    const LatLng(-3.295806, 114.581378),
    const LatLng(-3.294864, 114.582134),
    const LatLng(-3.294671, 114.582080),
    const LatLng(-3.295571, 114.583019),
    const LatLng(-3.295854, 114.583223),
    const LatLng(-3.297456, 114.581447),
    const LatLng(-3.297022, 114.581007),
  ];

  Future<void> _determinePositionAndMove() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Layanan lokasi tidak aktif.')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Izin lokasi ditolak.')));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Izin lokasi ditolak permanen, buka pengaturan.'),
        ),
      );
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    _mapController.move(LatLng(position.latitude, position.longitude), 15.0);
  }

  Future<void> _searchLocation() async {
    final query = _searchController.text;
    if (query.isEmpty) return;

    // Sembunyikan keyboard setelah search
    FocusScope.of(context).unfocus();

    try {
      final result = await locationFromAddress(query);
      if (result.isNotEmpty) {
        final latlng = LatLng(result.first.latitude, result.first.longitude);
        _mapController.move(latlng, 15.0);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lokasi "$query" tidak ditemukan')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mencari lokasi, periksa koneksi internet.'),
        ),
      );
    }
  }

  void _savePolygon() {
    if (_drawingPoints.length > 2) {
      setState(() {
        _polygons.add(
          Polygon(
            points: List.from(_drawingPoints),
            color: Colors.green.withOpacity(0.4),
            borderColor: Colors.green,
            borderStrokeWidth: 2,
          ),
        );
        _drawingPoints.clear();
        _isDrawing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_isDrawing ? 'Mode Menggambar' : 'Peta Banjarmasin'),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(
              _isDrawing ? Icons.close : Icons.edit_location_alt_outlined,
            ),
            tooltip: _isDrawing ? 'Batal Menggambar' : 'Gambar Poligon',
            onPressed: () {
              setState(() {
                _isDrawing = !_isDrawing;
                _drawingPoints.clear();
              });
            },
          ),
          if (_isDrawing && _drawingPoints.length > 2)
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Simpan Poligon',
              onPressed: _savePolygon,
            ),
        ],
      ),
      // PERBAIKAN 1: Pindahkan FAB ke sini agar tidak tertutup
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        elevation: 4,
        onPressed: _determinePositionAndMove,
        child: const Icon(Icons.my_location, color: Colors.black54),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(-3.310, 114.593),
              initialZoom: 13.5,
              onTap: (_, latlng) {
                if (_isDrawing) {
                  setState(() {
                    _drawingPoints.add(latlng);
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=TIHbKh1ipYKEv5heVCkc',
                additionalOptions: {'apiKey': 'TIHbKh1ipYKEv5heVCkc'},
              ),
              PolygonLayer(
                polygons: [
                  Polygon(
                    points: polibanAreaPoints,
                    color: Colors.blue.withOpacity(0.2),
                    borderColor: Colors.blue,
                    borderStrokeWidth: 2,
                  ),
                  ..._polygons,
                ],
              ),
              if (_isDrawing && _drawingPoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _drawingPoints,
                      color: Colors.orange,
                      strokeWidth: 3,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: locationItems.map((item) {
                  return Marker(
                    point: item['location'],
                    width: 35,
                    height: 35,
                    child: Icon(
                      item['icon'],
                      color: item['color'],
                      size: 35,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              CurrentLocationLayer(),
            ],
          ),
          Positioned(
            left: 8,
            top: 20,
            child: Column(
              children: [
                _categoryIcon(Icons.bar_chart, "Infrastruktur", Colors.red),
                const SizedBox(height: 10),
                _categoryIcon(Icons.eco, "Fisik & Lingkungan", Colors.green),
                const SizedBox(height: 10),
                _categoryIcon(Icons.travel_explore, "Potensi SDA", Colors.blue),
              ],
            ),
          ),
          // Hapus FAB dari dalam Stack ini
          DraggableScrollableSheet(
            initialChildSize: 0.25,
            minChildSize: 0.15,
            maxChildSize: 0.5,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
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
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Cari lokasi...",
                        // PERBAIKAN 2: Tambahkan tombol search di sini
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: _searchLocation,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            30,
                          ), // Buat lebih bulat
                          borderSide: BorderSide.none,
                        ),
                        fillColor: Colors.grey[200],
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                      ),
                      onSubmitted: (_) => _searchLocation(),
                    ),
                    const SizedBox(height: 12),
                    ...locationItems.map((item) {
                      return ListTile(
                        leading: Icon(item['icon'], color: item['color']),
                        title: Text(
                          item['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text("Kalimantan Selatan"),
                        onTap: () {
                          _mapController.move(item['location'], 16.0);
                        },
                      );
                    }).toList(),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _categoryIcon(IconData icon, String label, Color color) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 70,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
