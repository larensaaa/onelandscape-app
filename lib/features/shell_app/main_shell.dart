import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatelessWidget {
  const MainShell({
    required this.child, // 'child' adalah halaman yang akan ditampilkan (cth: HomeScreen)
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child, // Menampilkan halaman aktif di sini
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            elevation: 0,
            currentIndex: _calculateSelectedIndex(context),
            onTap: (index) => _onItemTapped(index, context),
            selectedItemColor: Colors.black, // warna icon aktif
            unselectedItemColor: Colors.black12, // warna icon tidak aktif
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
              BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'SKPD'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'User'),
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi untuk menentukan tab mana yang aktif berdasarkan rute saat ini
  int _calculateSelectedIndex(BuildContext context) {
    final GoRouter route = GoRouter.of(context);
    final String location = route.routerDelegate.currentConfiguration.uri
        .toString();
    if (location.startsWith('/home')) {
      return 0;
    }
    if (location.startsWith('/skpd')) {
      return 1;
    }
    if (location.startsWith('/user')) {
      return 2;
    }
    return 0; // Default ke Beranda
  }

  // Fungsi untuk navigasi saat item di-tap
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/skpd');
        break;
      case 2:
        context.go('/user');
        break;
    }
  }
}
