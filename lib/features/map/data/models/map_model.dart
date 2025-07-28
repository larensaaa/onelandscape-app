import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlong;

class LocationData {
  final int id;
  final String name;
  final String description;
  final latlong.LatLng position;
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

class AreaData {
  final int id;
  final String name;
  final List<latlong.LatLng> coordinates;
  final Color color;

  AreaData({
    required this.id,
    required this.name,
    required this.coordinates,
    this.color = Colors.purple,
  });
}