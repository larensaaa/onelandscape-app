import 'package:latlong2/latlong.dart';

class Lokasi {
  final String id;
  final String nama;
  final String deskripsi;
  final LatLng koordinat;
  final List<LatLng>? area; // Area poligon, bisa null jika tidak ada

  Lokasi({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.koordinat,
    this.area,
  });
}