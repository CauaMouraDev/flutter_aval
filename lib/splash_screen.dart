import 'package:flutter/material.dart';
import 'login_page.dart';

class SplashScreen extends StatelessWidget {
  static const routeName = '/splash';
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacementNamed(LoginPage.routeName);
    });
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            FlutterLogo(size: 100),
            SizedBox(height: 24),
            Text(
              'Flutter Quiz App',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 32,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
