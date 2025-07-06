import 'package:flutter/material.dart';

class TematikDetailPage extends StatelessWidget {
  const TematikDetailPage({
    required this.title,
    super.key,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          'Ini adalah halaman detail untuk: $title',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}