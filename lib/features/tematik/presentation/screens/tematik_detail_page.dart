import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Data model untuk setiap item tematik
class TematikItem {
  final String title;
  final String description;
  final String imageAsset;

  TematikItem({
    required this.title,
    required this.description,
    required this.imageAsset,
  });
}

// Halaman utama yang menampilkan daftar tematik
class DaftarTematikScreen extends StatelessWidget {
  const DaftarTematikScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Daftar data tematik, bisa diambil dari API nantinya
    final List<TematikItem> tematikItems = [
      TematikItem(
        title: 'Bencana & Konservasi',
        description: 'Deskripsi',
        imageAsset: 'assets/images/disaster.png', // Pastikan path aset benar
      ),
      TematikItem(
        title: 'Fisik & Lingkungan',
        description: 'Deskripsi',
        imageAsset: 'assets/images/environmentalism.png',
      ),
      TematikItem(
        title: 'Infrastruktur',
        description: 'Deskripsi',
        imageAsset: 'assets/images/infrastruktur.png',
      ),
      TematikItem(
        title: 'Keanekaragaman Hayati',
        description: 'Deskripsi',
        imageAsset: 'assets/images/wild-animals.png',
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.go('/home'), // Kembali ke halaman sebelumnya
        ),
        title: const Text(
          'Daftar Tematik',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        itemCount: tematikItems.length,
        itemBuilder: (context, index) {
          final item = tematikItems[index];
          return _buildTematikCard(context, item);
        },
      ),
      floatingActionButton: Padding(
        // 1. Bungkus dengan Padding untuk memberi jarak dari bawah
        padding: const EdgeInsets.only(
          bottom: 30.0,
          right: 15.0
        ), // Atur jarak sesuai kebutuhan
        child: FloatingActionButton(
          onPressed: () {
            // Aksi untuk menambah data baru
            context.push('/tematik-data');
          },
          backgroundColor: Colors.teal[300],
          elevation: 4,

          // 2. Gunakan CircleBorder() untuk memastikan bentuknya bulat sempurna
          shape: const CircleBorder(),

          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),

      // Anda tetap bisa mengatur posisi utama tombolnya
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // Widget untuk membuat satu kartu item tematik
  Widget _buildTematikCard(BuildContext context, TematikItem item) {
    return Card(
      color: Colors.white24,
      margin: const EdgeInsets.only(bottom: 25.0),
      elevation: 2.5,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12.0,
          horizontal: 25.0,
        ),
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          item.description,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        trailing: Image.asset(item.imageAsset, width: 60, height: 60),
        onTap: () {
          // Navigasi ke halaman detail tanpa mengirim parameter
          context.push('/tematik-detail');
        },
      ),
    );
  }
}
