import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onelandscape/features/tematik/data/models/tematik_model.dart';
import 'package:onelandscape/features/tematik/presentation/screens/tambah_edit_tematik_screen.dart';

class DaftarTematikScreen extends StatefulWidget {
  const DaftarTematikScreen({super.key});

  @override
  State<DaftarTematikScreen> createState() => _DaftarTematikScreenState();
}

class _DaftarTematikScreenState extends State<DaftarTematikScreen> {
  final List<TematikItem> _tematikItems = [
    TematikItem(title: 'Bencana & Konservasi', description: 'Deskripsi', imagePath: 'assets/images/disaster.png', isAsset: true),
    TematikItem(title: 'Fisik & Lingkungan', description: 'Deskripsi', imagePath: 'assets/images/environmentalism.png', isAsset: true),
    TematikItem(title: 'Infrastruktur', description: 'Deskripsi', imagePath: 'assets/images/infrastruktur.png', isAsset: true),
    TematikItem(title: 'Keanekaragaman Hayati', description: 'Deskripsi', imagePath: 'assets/images/wild-animals.png', isAsset: true),
  ];

  void _tambahTematik() async {
    final result = await Navigator.push<TematikItem>(
      context,
      MaterialPageRoute(builder: (context) => const TambahEditTematikScreen()),
    );
    if (result != null) {
      setState(() => _tematikItems.add(result));
    }
  }

  void _editTematik(int index) async {
    final result = await Navigator.push<TematikItem>(
      context,
      MaterialPageRoute(builder: (context) => TambahEditTematikScreen(tematikItem: _tematikItems[index])),
    );
    if (result != null) {
      setState(() => _tematikItems[index] = result);
    }
  }

  void _hapusTematik(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data'),
        content: const Text('Apakah Anda yakin ingin menghapus item ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              setState(() => _tematikItems.removeAt(index));
              Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // --- FUNGSI BARU UNTUK MENAMPILKAN MENU EDIT/HAPUS ---
  void _showEditDeleteOptions(int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context); // Tutup bottom sheet
                _editTematik(index);   // Jalankan fungsi edit
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Hapus'),
              onTap: () {
                Navigator.pop(context); // Tutup bottom sheet
                _hapusTematik(index);  // Jalankan fungsi hapus
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Daftar Tematik', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        itemCount: _tematikItems.length,
        itemBuilder: (context, index) {
          final item = _tematikItems[index];
          return _buildTematikCard(context, item, index);
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 30.0, right: 15.0),
        child: FloatingActionButton(
          onPressed: _tambahTematik,
          backgroundColor: Colors.teal[300],
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildTematikCard(BuildContext context, TematikItem item, int index) {
    Widget imageWidget;
    if (item.isAsset) {
      imageWidget = Image.asset(item.imagePath, width: 60, height: 60, fit: BoxFit.cover);
    } else {
      imageWidget = Image.file(File(item.imagePath), width: 60, height: 60, fit: BoxFit.cover);
    }

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 25.0),
      elevation: 2.5,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      // --- PERUBAHAN: Gunakan GestureDetector untuk menangkap klik lama ---
      child: GestureDetector(
        onLongPress: () {
          _showEditDeleteOptions(index); // Panggil menu saat klik lama
        },
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 25.0),
          title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          subtitle: Text(item.description, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          // --- PERUBAHAN: Gambar dipindahkan kembali ke trailing (kanan) ---
          trailing: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: imageWidget,
          ),
          // Aksi tombol edit/hapus di sini sudah dihilangkan
          onTap: () => context.push('/tematik-detail', extra: item),
        ),
      ),
    );
  }
}