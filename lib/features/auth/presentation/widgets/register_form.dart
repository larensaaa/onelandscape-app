import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onelandscape/features/auth/presentation/providers/auth_provider.dart'; // Sesuaikan path
import 'package:provider/provider.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Fungsi untuk menangani register
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    bool isSuccess = await authProvider.register(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (isSuccess && context.mounted) {
      // Jika sukses, tampilkan notifikasi dan KEMBALI
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil! Silakan login.'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Terjadi kesalahan saat registrasi.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoading = context.watch<AuthProvider>().isLoading;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input Field Nama
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person_outline),
                hintText: 'Nama Lengkap',
              ),
              validator: (value) => value == null || value.isEmpty
                  ? 'Nama tidak boleh kosong'
                  : null,
            ),
            const SizedBox(height: 16),

            // Input Field Email
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.email_outlined),
                hintText: 'Email',
              ),
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Email tidak boleh kosong';
                if (!value.contains('@')) return 'Email tidak valid';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Input Field Password
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.lock_outline),
                hintText: 'Password',
              ),
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Password tidak boleh kosong';
                if (value.length < 6) return 'Password minimal 6 karakter';
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Tombol Daftar
            ElevatedButton.icon(
              onPressed: isLoading ? null : _handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: isLoading
                  ? Container(
                      width: 24,
                      height: 24,
                      padding: const EdgeInsets.all(2.0),
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : const Icon(Icons.person_add_alt_1),
              label: Text(isLoading ? 'MEMPROSES...' : 'Daftar Akun',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
