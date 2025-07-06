
import 'package:flutter/material.dart';
import 'package:onelandscape/features/tematik_crud/data/models/tematik_model.dart';
import 'package:uuid/uuid.dart';

class TematikFormPage extends StatefulWidget {
  final Tematik? tematik;
  const TematikFormPage({super.key, this.tematik});

  @override
  State<TematikFormPage> createState() => _TematikFormPageState();
}

class _TematikFormPageState extends State<TematikFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  String? _kategori;
  final List<String> _kategoriList = ['Kategori 1', 'Kategori 2', 'Kategori 3'];

  @override
  void initState() {
    super.initState();
    if (widget.tematik != null) {
      _judulController.text = widget.tematik!.judul;
      _deskripsiController.text = widget.tematik!.deskripsi;
      _kategori = widget.tematik!.kategori;
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final tematik = Tematik(
        id: widget.tematik?.id ?? const Uuid().v4(),
        judul: _judulController.text,
        kategori: _kategori ?? '',
        deskripsi: _deskripsiController.text,
      );
      Navigator.pop(context, tematik);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: Text(widget.tematik == null ? 'Tambah Data Tematik' : 'Edit Data Tematik'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Judul'),
              TextFormField(
                controller: _judulController,
                decoration: const InputDecoration(
                  hintText: 'Judul',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Judul wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              const Text('Kategori'),
              DropdownButtonFormField<String>(
                value: _kategori,
                items: _kategoriList
                    .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                    .toList(),
                onChanged: (v) => setState(() => _kategori = v),
                decoration: const InputDecoration(
                  hintText: 'Pilih Kategori',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Kategori wajib dipilih' : null,
              ),
              const SizedBox(height: 16),
              const Text('Deskripsi'),
              TextFormField(
                controller: _deskripsiController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Deskripsi wajib diisi' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _save,
                  child: const Text('Simpan', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
