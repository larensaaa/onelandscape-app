// File: lib/main.dart (PASTIKAN SEPERTI INI)

import 'package:flutter/material.dart';
import 'package:onelandscape/features/auth/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:onelandscape/core/routing/app_route.dart';

void main() {
  final AuthProvider authProvider = AuthProvider();

  runApp(
    ChangeNotifierProvider.value(
      value: authProvider,
      child: MyApp(authProvider: authProvider),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthProvider authProvider;

  const MyApp({super.key, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter(authProvider);

    return MaterialApp.router(
      routerConfig: appRouter.router,
      title: 'Mobile GIS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
    );
  }
}
