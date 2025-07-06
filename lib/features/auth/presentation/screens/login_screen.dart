import 'package:flutter/material.dart';
import '../widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Background hijau atas
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 410,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0xFF218221),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 100,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Text(
                            'MOBILE GIS',
                            style: TextStyle(
                              fontSize: 37,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // LoginForm melayang di atas background
            Positioned(top: 260, left: 65, right: 65, child: LoginForm()),
          ],
        ),
      ),
    );
  }
}
