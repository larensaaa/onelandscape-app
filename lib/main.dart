import 'package:flutter/material.dart';
import 'package:onelandscape/features/auth/presentation/providers/auth_provider.dart'; // Sesuaikan path
import 'package:provider/provider.dart';
import 'core/routing/app_route.dart'; // Sesuaikan path

void main() {
  // Anda harus MEMBUNGKUS MyApp DENGAN Provider,
  // lalu HASILNYA dimasukkan ke dalam runApp.
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'Mobile GIS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
    );
  }
}