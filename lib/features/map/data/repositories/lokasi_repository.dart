import 'package:latlong2/latlong.dart';
import '../models/lokasi_model.dart';

class LokasiRepository {
  // Data dummy, nantinya ini akan diambil dari API
  final List<Lokasi> _lokasiList = [
    Lokasi(
      id: '1',
      nama: 'Politeknik Negeri Banjarmasin',
      deskripsi: 'Kampus Vokasi Unggulan di Kalimantan.',
      koordinat: const LatLng(-3.296332, 114.582371),
      area: [
        const LatLng(-3.297022, 114.581007),
        const LatLng(-3.296186, 114.581442),
        const LatLng(-3.295806, 114.581378),
        const LatLng(-3.294864, 114.582134),
        const LatLng(-3.294671, 114.582080),
        const LatLng(-3.295571, 114.583019),
        const LatLng(-3.295854, 114.583223),
        const LatLng(-3.297456, 114.581447),
        const LatLng(-3.297022, 114.581007),
      ],
    ),
    Lokasi(
      id: '2',
      nama: 'Duta Mall Banjarmasin',
      deskripsi: 'Pusat perbelanjaan terbesar di Banjarmasin.',
      koordinat: const LatLng(-3.322712, 114.602978),
      area: null, // Tidak memiliki area poligon
    ),
  ];

  List<Lokasi> getAllLokasi() {
    return _lokasiList;
  }
}