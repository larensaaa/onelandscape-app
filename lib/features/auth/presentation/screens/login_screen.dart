import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import '../widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF386641),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 55),
            // Logo
            ClipOval(
              child: Container(
                color: Colors.grey[200],
                width: 140,
                height: 140,
                child: Image.asset(
                  'assets/images/gis.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Judul
            Text(
              'ONE LANDSCAPE',
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Color(0xFFF2E8CF),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 45),
            // Form Container
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5ECD6),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(26),
                    topRight: Radius.circular(26),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 55,
                    vertical: 30,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Scrollable form & daftar
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              const LoginForm(),
                              const SizedBox(height: 50),
                              Divider(color: Colors.grey[400]),
                              const SizedBox(height: 30),
                              Text.rich(
                                TextSpan(
                                  text: 'Belum punya akun? ',
                                  style: GoogleFonts.inter(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Daftar disini',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                        fontSize: 17,
                                      ),
                                      recognizer: TapGestureRecognizer()
  ..onTap = () => context.go('/register'),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 32.0, bottom: 8),
                        child: Text(
                          'copyright text',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
