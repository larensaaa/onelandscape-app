import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onelandscape/features/auth/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Jalankan pengecekan setelah frame pertama selesai di-build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndNavigate();
    });
  }

  Future<void> _checkAuthAndNavigate() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkLoginStatus();

    // Navigasi berdasarkan status autentikasi
    if (mounted) {
      if (authProvider.isAuthenticated) {
        context.go('/home'); // Jika sudah login, ke halaman utama
      } else {
        context.go('/login'); // Jika belum, ke halaman login
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tampilan loading sederhana
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}