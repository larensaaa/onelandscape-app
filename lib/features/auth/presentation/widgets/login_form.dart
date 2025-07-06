import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        // Input Field Username
        _buildTextField(controller: _usernameController, hint: 'Username'),
        const SizedBox(height: 20),

        // Input Field Password
        _buildTextField(
          controller: _passwordController,
          hint: 'Password',
          isObscure: true,
        ),
        const SizedBox(height: 100),

        // Tombol Login
        _buildLoginButton(),
        const SizedBox(height: 20),
      ],
    );
  }

  // Widget untuk TextField
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool isObscure = false,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 20, color: Colors.black),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 35),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 1),
        ),
      ),
    );
  }

  // Widget tombol login
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          final username = _usernameController.text;
          final password = _passwordController.text;
          print('Username: $username, Password: $password');
          // Logika sementara untuk masuk ke halaman home
          GoRouter.of(context).go('/home');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 34, 225, 47),
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          shadowColor: Colors.black.withOpacity(0.25),
          side: const BorderSide(color: Colors.black, width: 1.5),
        ),
        child: const Text(
          'Login',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
