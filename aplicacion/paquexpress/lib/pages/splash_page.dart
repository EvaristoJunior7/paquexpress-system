import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_page.dart';
import 'home_page.dart';
import '../core/storage.dart';
import '../core/theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  _checkSession() async {
    await Future.delayed(Duration(seconds: 2)); // Efecto de carga
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('auth_token') != null) {
      if (mounted) {
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (_) => const HomePage())
        );
      }
    } else {
      if (mounted) {
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (_) => const LoginPage())
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.kPrimaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping_rounded, 
              size: 100, 
              color: AppTheme.kAccentColor
            ),
            SizedBox(height: 20),
            Text(
              "PAQUEXPRESS", 
              style: TextStyle(
                color: Colors.white, 
                fontSize: 24, 
                fontWeight: FontWeight.bold, 
                letterSpacing: 2
              ),
            ),
            SizedBox(height: 10),
            CircularProgressIndicator(color: AppTheme.kAccentColor),
          ],
        ),
      ),
    );
  }
}