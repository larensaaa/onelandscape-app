import 'package:flutter/material.dart';
import 'package:onelandscape/features/tematik_crud/data/models/tematik_model.dart';
import 'package:onelandscape/features/tematik_crud/data/repositories/tematik_repository.dart';
import 'tematik_form_page.dart';

class TematikDataPage extends StatefulWidget {
  const TematikDataPage({super.key});

  @override
  State<TematikDataPage> createState() => _TematikDataPageState();
}

class _TematikDataPageState extends State<TematikDataPage> {
  final TematikRepository repo = TematikRepository();

  void _openForm({Tematik? data}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TematikFormPage(
          tematik: data,
        ),
      ),
    );
    if (result != null && result is Tematik) {
      setState(() {
        if (data == null) {
          repo.add(result);
        } else {
          repo.update(data.id, result);
        }
      });
    }
  }

  void _delete(String id) {
    setState(() {
      repo.delete(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = repo.getAll();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Text('Data Tematik'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Judul')),
                  DataColumn(label: Text('Kategori')),
                  DataColumn(label: Text('Deskripsi')),
                  DataColumn(label: Text('Aksi')),
                ],
                rows: items.map((t) => DataRow(cells: [
                  DataCell(Text(t.judul)),
                  DataCell(Text(t.kategori)),
                  DataCell(Text(t.deskripsi)),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.green),
                        onPressed: () => _openForm(data: t),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _delete(t.id),
                      ),
                    ],
                  )),
                ])).toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () => _openForm(),
                child: const Text('Tambah', style: TextStyle(fontSize: 18)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
