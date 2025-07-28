class TematikItem {
  final String title;
  final String description;
  final String imagePath;
  final bool isAsset;
  final String? kategori;

  TematikItem({
    required this.title,
    required this.description,
    required this.imagePath,
    this.isAsset = false,
    this.kategori,
  });
}