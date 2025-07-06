import 'package:flutter/material.dart';
import 'app_route.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {  
    return MaterialApp.router(
      routerConfig: router, // Menggunakan konfigurasi route yang telah dibuat
      title: 'Mobile GIS',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
    );
  } 
}