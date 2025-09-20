import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onelandscape/features/auth/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Warna konsisten
  static const _gold = Color(0xFFDBBC0C);
  static const _error = Color(0xFFB3261E); //error

  InputDecoration _inputDecoration(String hint) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _gold, width: 1),
    );
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      border: border,
      enabledBorder: border,
      focusedBorder: border,
      // Saat error: tetap border emas, hanya teks error yang merah dan kecil
      errorBorder: border,
      focusedErrorBorder: border,
      errorStyle: GoogleFonts.inter(
        color: _error,
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        height: 1.1,
      ),
      errorMaxLines: 2,
    );
  }

  void _showErrorSnack(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          backgroundColor: Colors.transparent,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _error,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    bool isSuccess = await authProvider.login(
      _usernameController.text,
      _passwordController.text,
    );

    if (context.mounted) {
      if (isSuccess) {
        context.go('/home');
      } else {
        _showErrorSnack(
          authProvider.errorMessage ?? 'Username/Password salah.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoading = context.watch<AuthProvider>().isLoading;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: 20),
          SizedBox(
            width: 267,
            height: 40,
            child: TextFormField(
              controller: _usernameController,
              decoration: _inputDecoration('Username'),
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Username tidak boleh kosong';
                return null;
              },
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: 267,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  height: 40,
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: _inputDecoration('Password'),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Password tidak boleh kosong';
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    // Aksi lupa username/password
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Lupa Username/Password?',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                      color: const Color(0xFF000000),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          // Tombol Login
          Center(
            child: SizedBox(
              width: 148,
              height: 61,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromRGBO(0, 0, 0, 0.25), // #000000 25%
                      offset: const Offset(0, 4), // X: 0, Y: 4
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFF6A994E), // Outline hijau
                    width: 1,
                  ),
                ),
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF183F18),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                      // side dihapus, outline pakai BoxDecoration di atas
                    ),
                    elevation: 0, // elevation 0 agar tidak double shadow
                    shadowColor: Colors.transparent,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Text(
                          'Login',
                          style: GoogleFonts.openSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
