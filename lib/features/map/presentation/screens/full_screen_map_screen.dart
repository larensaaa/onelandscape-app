import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';

class FullScreenMapScreen extends StatefulWidget {
  const FullScreenMapScreen({super.key});

  @override
  State<FullScreenMapScreen> createState() => _FullScreenMapScreenState();
}

class _FullScreenMapScreenState extends State<FullScreenMapScreen> {
  final MapController _mapController = MapController();

  // Variabel untuk menyimpan titik-titik polygon yang dipilih
  List<LatLng>? _selectedPolygonPoints;

  // Fungsi untuk menampilkan dialog informasi
  void showMarkerDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('Tutup'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk mendapatkan lokasi pengguna saat ini
  Future<void> _determinePositionAndMove() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Layanan lokasi tidak aktif. Mohon aktifkan.'),
          ),
        );
      }
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Izin lokasi ditolak.')));
        }
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin lokasi ditolak permanen.')),
        );
      }
      return;
    }
    final position = await Geolocator.getCurrentPosition();
    _mapController.move(LatLng(position.latitude, position.longitude), 15.0);
  }

  @override
  Widget build(BuildContext context) {
    // Daftar titik-titik sudut untuk poligon Poliban
    final List<LatLng> polibanAreaPoints = [
      const LatLng(-3.2970224235033, 114.581007957459),
      const LatLng(-3.29618695908693, 114.581442475319),
      const LatLng(-3.29580671543432, 114.581378102303),
      const LatLng(-3.29486413899283, 114.582134485245),
      const LatLng(-3.29467133915618, 114.582080841064),
      const LatLng(-3.29557107140766, 114.58301961422),
      const LatLng(-3.29585491534199, 114.583223462105),
      const LatLng(-3.2974562220581, 114.581447839737),
      const LatLng(
        -3.2970224235033,
        114.581007957459,
      ), 
    ];

    // Daftar marker Sementara Belum pakai data dari API
    final List<Marker> markers = [
      Marker(
        width: 80.0,
        height: 80.0,
        point: const LatLng(-3.296332, 114.582371), // Poliban
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedPolygonPoints = polibanAreaPoints;
            });
            showMarkerDialog(
              'Informasi Lokasi',
              'Politeknik Negeri Banjarmasin',
            );
          },
          child: Icon(
            Icons.location_on,
            color: Colors.blue.shade700,
            size: 20.0,
          ),
        ),
      ),
      Marker(
        width: 80.0,
        height: 80.0,
        point: const LatLng(-3.322712, 114.602978), // Duta Mall
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedPolygonPoints = null;
            });
            showMarkerDialog('Informasi Lokasi', 'Duta Mall Banjarmasin');
          },
          child: Icon(
            Icons.location_on,
            color: Colors.red.shade700,
            size: 20.0,
          ),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Peta Interaktif')),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: const LatLng(-3.317, 114.590), // Banjarmasin
          initialZoom: 13.0,
          onTap: (_, __) {
            // Sembunyikan poligon saat peta diklik
            setState(() {
              _selectedPolygonPoints = null;
            });
          },
        ),
        children: [
          // Layer Peta dari MapTiler
          TileLayer(
            urlTemplate:
                'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}{r}.png?key={apiKey}',
            additionalOptions: {
              'apiKey':
                  'TIHbKh1ipYKEv5heVCkc', 
            },
          ),

          // Layer Poligon (hanya muncul jika dipilih)
          if (_selectedPolygonPoints != null)
            PolygonLayer(
              polygons: [
                Polygon(
                  points: _selectedPolygonPoints!,
                  color: Colors.blue.withOpacity(0.1),
                  borderColor: Colors.blue,
                  borderStrokeWidth: 2.0,
                ),
              ],
            ),

          // Layer untuk semua marker
          MarkerLayer(markers: markers),

          // Layer untuk menampilkan lokasi pengguna saat ini
          CurrentLocationLayer(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _determinePositionAndMove,
        tooltip: 'Cari Lokasi Saya',
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
