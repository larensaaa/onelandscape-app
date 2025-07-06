import 'package:onelandscape/features/tematik_crud/data/models/tematik_model.dart';

class TematikRepository {
  final List<Tematik> _data = [];

  List<Tematik> getAll() => List.unmodifiable(_data);

  void add(Tematik tematik) {
    _data.add(tematik);
  }

  void update(String id, Tematik newData) {
    final idx = _data.indexWhere((t) => t.id == id);
    if (idx != -1) _data[idx] = newData;
  }

  void delete(String id) {
    _data.removeWhere((t) => t.id == id);
  }
}
