import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

// Model untuk data lokasi/marker
class LocationData {
  final int id;
  final String name;
  final String description;
  final LatLng position;
  final IconData icon;
  final Color color;

  LocationData({
    required this.id,
    required this.name,
    this.description = '',
    required this.position,
    this.icon = Icons.location_on,
    this.color = Colors.red,
  });
}

// Model untuk data area/poligon
class AreaData {
  final int id;
  final String name;
  final List<LatLng> coordinates;
  final Color color;

  AreaData({
    required this.id,
    required this.name,
    required this.coordinates,
    this.color = Colors.purple,
  });
}