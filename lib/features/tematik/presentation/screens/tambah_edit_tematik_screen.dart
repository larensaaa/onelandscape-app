import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onelandscape/features/tematik/data/models/tematik_model.dart';

class TambahEditTematikScreen extends StatefulWidget {
  final TematikItem? tematikItem;
  const TambahEditTematikScreen({super.key, this.tematikItem});

  @override
  State<TambahEditTematikScreen> createState() =>
      _TambahEditTematikScreenState();
}

class _TambahEditTematikScreenState extends State<TambahEditTematikScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _judulController;
  late TextEditingController _deskripsiController;
  String? _kategoriValue;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(
      text: widget.tematikItem?.title ?? '',
    );
    _deskripsiController = TextEditingController(
      text: widget.tematikItem?.description ?? '',
    );
    _kategoriValue = widget.tematikItem?.kategori;
    if (widget.tematikItem != null && !widget.tematikItem!.isAsset) {
      _imageFile = File(widget.tematikItem!.imagePath);
    }
  }

  Future<void> _pilihGambar() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _simpan() {
    if (_formKey.currentState!.validate()) {
      String imagePathResult;
      bool isAssetResult;

      if (_imageFile != null) {
        imagePathResult = _imageFile!.path;
        isAssetResult = false;
      } else if (widget.tematikItem != null) {
        imagePathResult = widget.tematikItem!.imagePath;
        isAssetResult = widget.tematikItem!.isAsset;
      } else {
        imagePathResult =
            'assets/images/default.png'; // Pastikan Anda punya gambar ini
        isAssetResult = true;
      }

      final newItem = TematikItem(
        title: _judulController.text,
        description: _deskripsiController.text,
        imagePath: imagePathResult,
        isAsset: isAssetResult,
        kategori: _kategoriValue,
      );
      Navigator.pop(context, newItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.tematikItem == null
              ? 'Tambah Data Tematik'
              : 'Edit Data Tematik',
        ),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildImagePicker(),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _judulController,
                  decoration: const InputDecoration(
                    labelText: 'Judul',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Judul tidak boleh kosong'
                      : null,
                ),

                const SizedBox(height: 16),
                TextFormField(
                  controller: _deskripsiController,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Deskripsi tidak boleh kosong'
                      : null,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _simpan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Simpan',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _imageFile != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(_imageFile!, fit: BoxFit.cover),
                )
              : (widget.tematikItem != null && widget.tematikItem!.isAsset
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          widget.tematikItem!.imagePath,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Center(child: Text('Belum ada gambar'))),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _pilihGambar,
          icon: const Icon(Icons.image),
          label: const Text('Pilih Gambar dari Galeri'),
        ),
      ],
    );
  }
}
