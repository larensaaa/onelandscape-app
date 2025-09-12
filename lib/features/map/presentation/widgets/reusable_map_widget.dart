import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:provider/provider.dart';
import '../../data/models/map_model.dart';
import '../providers/map_provider.dart';

bool _isPointInPolygon(latlong.LatLng point, List<latlong.LatLng> polygon) {
  if (polygon.length < 3) return false;
  int crossings = 0;
  for (int i = 0; i < polygon.length; i++) {
    latlong.LatLng p1 = polygon[i];
    latlong.LatLng p2 = polygon[(i + 1) % polygon.length];
    if (((p1.latitude <= point.latitude && point.latitude < p2.latitude) ||
            (p2.latitude <= point.latitude && point.latitude < p1.latitude)) &&
        (point.longitude <
            (p2.longitude - p1.longitude) *
                    (point.latitude - p1.latitude) /
                    (p2.latitude - p1.latitude) +
                p1.longitude)) {
      crossings++;
    }
  }
  return crossings % 2 == 1;
}

class ReusableMapWidget extends StatelessWidget {
  final List<LocationData> locations;
  final List<AreaData> areas;
  final latlong.LatLng? selectedLocationMarker;
  final Function(latlong.LatLng)? onMapTap;
  final Function(LocationData)? onLocationLongPress;
  final Function(AreaData)? onAreaLongPress;

  const ReusableMapWidget({
    super.key,
    this.locations = const [],
    this.areas = const [],
    this.selectedLocationMarker,
    this.onMapTap,
    this.onLocationLongPress,
    this.onAreaLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MapProvider>();
    return Scaffold(
      appBar: _buildAppBar(context, provider),
      body: FlutterMap(
        mapController: provider.mapController,
        options: MapOptions(
          initialCenter: const latlong.LatLng(-3.310, 114.593),
          initialZoom: 13.5,
          onTap: (pos, latlng) {
            if (provider.isDrawing) {
              provider.addDrawingPoint(latlng);
              return;
            }
            bool polygonTapped = false;
            for (final area in areas.reversed) {
              if (_isPointInPolygon(latlng, area.coordinates)) {
                // geser kamera sedikit agar popup info tidak overflow di bottom
                if (area.coordinates.isNotEmpty) {
                  final midpoint =
                      area.coordinates[area.coordinates.length ~/ 2];
                  const double offsetLat = 0.003;
                  final target = latlong.LatLng(
                    midpoint.latitude - offsetLat,
                    midpoint.longitude,
                  );
                  double zoom = 16.0;
                  try {
                    final dynamic ctrl = provider.mapController;
                    final dynamic z = ctrl?.zoom;
                    if (z is num) zoom = z.toDouble();
                    // bergerak ke target
                    ctrl?.move(target, zoom);
                  } catch (_) {
                    // fallback: ignore
                  }
                }
                // beri waktu sedikit agar map sudah bergerak, lalu tampilkan info sebagai bottom sheet
                Future.delayed(
                  const Duration(milliseconds: 150),
                  () => _showItemBottomSheet(context, provider, area),
                );
                polygonTapped = true;
                break;
              }
            }
            if (!polygonTapped) {
              if (provider.selectedItem != null) {
                provider.deselectItem();
              } else {
                onMapTap?.call(latlng);
              }
            }
          },
          onLongPress: (pos, latlng) {
            if (provider.isDrawing) return;
            for (final area in areas.reversed) {
              if (_isPointInPolygon(latlng, area.coordinates)) {
                onAreaLongPress?.call(area);
                return;
              }
            }
          },
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key={apiKey}',
            additionalOptions: {'apiKey': 'TIHbKh1ipYKEv5heVCkc'},
          ),
          PolygonLayer(
            polygons: areas
                .map(
                  (area) => Polygon(
                    points: area.coordinates,
                    color: area.color.withAlpha(77),
                    borderColor: area.color,
                    borderStrokeWidth: 2,
                  ),
                )
                .toList(),
          ),
          MarkerLayer(
            markers: locations
                .map(
                  (loc) => Marker(
                    point: loc.position,
                    width: 30,
                    height: 30,
                    child: GestureDetector(
                      onTap: () async {
                        // Geser kamera sedikit ke utara sebelum menampilkan popup supaya tidak overflow
                        const double offsetLat = 0.003;
                        final target = latlong.LatLng(
                          loc.position.latitude - offsetLat,
                          loc.position.longitude,
                        );
                        double zoom = 16.0;
                        try {
                          final dynamic ctrl = provider.mapController;
                          final dynamic z = ctrl?.zoom;
                          if (z is num) zoom = z.toDouble();
                          ctrl?.move(target, zoom);
                        } catch (_) {
                          // ignore dan lanjut
                        }
                        await Future.delayed(const Duration(milliseconds: 150));
                        _showItemBottomSheet(context, provider, loc);
                      },
                      onLongPress: () => onLocationLongPress?.call(loc),
                      child: Icon(loc.icon, color: loc.color, size: 40),
                    ),
                  ),
                )
                .toList(),
          ),
          if (selectedLocationMarker != null && !provider.isDrawing)
            MarkerLayer(
              markers: [
                Marker(
                  point: selectedLocationMarker!,
                  child: const Icon(
                    Icons.add_location_alt,
                    color: Colors.green,
                    size: 45,
                  ),
                ),
              ],
            ),
          if (provider.isDrawing)
            MarkerLayer(
              markers: provider.drawingPoints.map((point) {
                return Marker(
                  width: 20,
                  height: 20,
                  point: point,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.purple, width: 3),
                    ),
                  ),
                );
              }).toList(),
            ),
          if (provider.isDrawing && provider.drawingPoints.isNotEmpty)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: provider.drawingPoints,
                  color: Colors.purple,
                  strokeWidth: 4,
                ),
              ],
            ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, MapProvider provider) {
    return AppBar(
      title: Text(provider.isDrawing ? 'Mode Menggambar' : 'Peta'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          if (Navigator.canPop(context)) Navigator.pop(context);
        },
      ),
      actions: [
        if (provider.isDrawing && provider.drawingPoints.length > 2)
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Simpan Area',
            onPressed: () => provider.submitDrawnArea(context),
          ),
      ],
    );
  }

// Tambahkan helper untuk menampilkan info sebagai bottom sheet
  void _showItemBottomSheet(BuildContext context, MapProvider provider, dynamic item) {
    final String title = (item is LocationData) ? item.name : (item is AreaData ? item.name : 'Detail');
    final String subtitle = (item is LocationData)
        ? (item.description.isEmpty ? 'Tidak ada deskripsi' : item.description)
        : (item is AreaData ? (item.description ?? 'Tidak ada deskripsi') : '');
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: const Text('Tutup'),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;

