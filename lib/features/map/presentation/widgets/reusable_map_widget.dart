import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:provider/provider.dart';
import '../../data/models/map_model.dart';
import '../providers/map_provider.dart';

// Fungsi bantu untuk memeriksa apakah suatu titik berada di dalam poligon
bool _isPointInPolygon(latlong.LatLng point, List<latlong.LatLng> polygon) {
  if (polygon.length < 3) {
    return false;
  }
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
  final Function(String, List<latlong.LatLng>)? onAreaSubmit;
  final Function(LocationData)? onLocationLongPress;
  final Function(AreaData)? onAreaLongPress;

  const ReusableMapWidget({
    super.key,
    this.locations = const [],
    this.areas = const [],
    this.selectedLocationMarker,
    this.onMapTap,
    this.onAreaSubmit,
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
                provider.selectItem(area);
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
            urlTemplate: 'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key={apiKey}',
            additionalOptions: {'apiKey': 'TIHbKh1ipYKEv5heVCkc'},
          ),
          PolygonLayer(
            polygons: areas
                .map((area) => Polygon(
                      points: area.coordinates,
                      color: area.color.withAlpha(77),
                      borderColor: area.color,
                      borderStrokeWidth: 2,
                    ))
                .toList(),
          ),
          MarkerLayer(
            markers: locations
                .map((loc) => Marker(
                      point: loc.position,
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () => provider.selectItem(loc),
                        onLongPress: () => onLocationLongPress?.call(loc),
                        child: Icon(loc.icon, color: loc.color, size: 40),
                      ),
                    ))
                .toList(),
          ),
          if (selectedLocationMarker != null && !provider.isDrawing)
            MarkerLayer(markers: [
              Marker(
                point: selectedLocationMarker!,
                child: const Icon(Icons.add_location_alt, color: Colors.green, size: 45),
              ),
            ]),
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
            PolylineLayer(polylines: [
              Polyline(points: provider.drawingPoints, color: Colors.purple, strokeWidth: 4),
            ]),
          if (provider.selectedItem != null)
            MarkerLayer(
              markers: [_buildInfoPopup(provider.selectedItem)],
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
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
      ),
      actions: [
        if (provider.isDrawing && provider.drawingPoints.length > 2)
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Simpan Area',
            onPressed: () => provider.saveArea(context: context, onAreaSubmit: onAreaSubmit),
          )
      ],
    );
  }

  Marker _buildInfoPopup(dynamic item) {
    latlong.LatLng position;
    String name;

    if (item is LocationData) {
      position = item.position;
      name = item.name;
    } else if (item is AreaData) {
      if (item.coordinates.length < 2) {
        return Marker(point: latlong.LatLng(0, 0), child: Container());
      }
      final bounds = LatLngBounds.fromPoints(item.coordinates);
      position = bounds.center;
      name = item.name;
    } else {
      return Marker(point: latlong.LatLng(0, 0), child: Container());
    }

    return Marker(
      point: position,
      width: 150,
      height: 50,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
            ),
            child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ),
          ClipPath(
            clipper: _ArrowClipper(),
            child: Container(
              width: 15,
              height: 10,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}

class _ArrowClipper extends CustomClipper<Path> {
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
}