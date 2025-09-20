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
      backgroundColor: const Color(0xFF183F18),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 350,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/login_header_bg.jpg'),
                  fit: BoxFit.cover,
                ),
              ),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: const AssetImage(
                      'assets/images/gis.png',
                    ), 
                  ),
                  const SizedBox(height: 25),
                  Text(
                    'ONE LANDSCAPE',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFFFFFF),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),

            // Widget Form
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(26),
                    topRight: Radius.circular(26),
                  ),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/login_form_bg.jpg'),
                    fit: BoxFit.cover,
                    // overlay 57%
                    colorFilter: ColorFilter.mode(
                      Color(0x91FFFFFF),
                      BlendMode.srcATop,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 55,
                    vertical: 10,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // form & daftar
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
                        padding: EdgeInsets.only(top: 32.0, bottom: 1),
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
