import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:onelandscape/features/auth/data/models/user_model.dart'; // Sesuaikan path

class LocationData {
  final int id;
  final String name;
  final String description;
  final latlong.LatLng position;
  final User? user;
  final IconData icon;
  final Color color;

  LocationData({
    required this.id,
    required this.name,
    required this.description,
    required this.position,
    this.user,
    this.icon = Icons.location_on,
    this.color = Colors.red,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      id: json['id'],
      name: json['title'] ?? 'Tanpa Nama',
      description: json['description'] ?? '',
      position: latlong.LatLng(
        double.tryParse(json['latitude']?.toString() ?? '0.0') ?? 0.0,
        double.tryParse(json['longitude']?.toString() ?? '0.0') ?? 0.0,
      ),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
}

class AreaData {
  final int id;
  final String name;
  final String description;
  final List<latlong.LatLng> coordinates;
  final User? user;
  final Color color;

  AreaData({
    required this.id,
    required this.name,
    required this.description,
    required this.coordinates,
    this.user,
    this.color = Colors.blue,
  });

  factory AreaData.fromJson(Map<String, dynamic> json) {
    List<latlong.LatLng> coordsList = [];
    if (json['coordinates'] is List) {
     
      coordsList = (json['coordinates'] as List).map((coord) {
        
        if (coord is Map) {
          final lat = double.tryParse(coord['lat']?.toString() ?? '0.0') ?? 0.0;
          final lng = double.tryParse(coord['lng']?.toString() ?? '0.0') ?? 0.0;
          return latlong.LatLng(lat, lng);
        }
        return latlong.LatLng(0,0); 
      }).toList();
    }

    return AreaData(
      id: json['id'],
      name: json['name'] ?? 'Tanpa Nama',
      description: json['description'] ?? '',
      coordinates: coordsList,
      color: Colors.blue,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
      
        'coordinates': coordinates.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
      };
}