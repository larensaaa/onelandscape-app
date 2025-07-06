import 'package:flutter/material.dart';

class SkpdScreen extends StatelessWidget {
  const SkpdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Halaman SKPD'),),
      body: Center(
        child: Text('Ini adalah Halaman SKPD'),
      ),
    );
  }
}