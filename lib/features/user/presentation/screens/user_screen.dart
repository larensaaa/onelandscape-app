import 'package:flutter/material.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Halaman User')),  
      body: Center(
        child: Text('Ini adalah Halaman User'),
      ),
    );
  }
}