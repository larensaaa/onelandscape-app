import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onelandscape/features/auth/presentation/providers/auth_provider.dart'; // Sesuaikan path
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (user != null) ...[
              Center(
                child: CircleAvatar(
                  radius: 50,
                  child: const Icon(Icons.person, size: 50),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  user.email ?? 'Tidak ada email',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Chip(
                  label: Text(
                    user.userLevel?.name.toUpperCase() ?? 'RRR',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.blueAccent,
                ),
              ),
            ],

            const Spacer(),

            ElevatedButton.icon(
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () async {
                await authProvider.logout();

                if (context.mounted) {
                  context.go('/login');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
