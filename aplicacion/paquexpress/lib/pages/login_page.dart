import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../core/api.dart';
import '../core/storage.dart';
import '../core/theme.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _doLogin() async {
    setState(() => _loading = true);
    try {
      final res = await http.post(
        Uri.parse('$apiEndpoint/token'),
        body: {'username': _userCtrl.text, 'password': _passCtrl.text},
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        await Storage.saveToken(data['access_token']);
        if (mounted) {
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (_) => const HomePage())
          );
        }
      } else {
        _snack('Credenciales incorrectas', isError: true);
      }
    } catch (e) {
      _snack('Error de conexión');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.redAccent : AppTheme.kPrimaryColor,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Curvo (EXACTAMENTE IGUAL AL ORIGINAL)
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: AppTheme.kPrimaryColor,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(60)),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map_outlined, size: 80, color: Colors.white),
                    SizedBox(height: 10),
                    Text(
                      "Bienvenido Agente", 
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: 28, 
                        fontWeight: FontWeight.w300
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 40),
            
            // Formulario (EXACTAMENTE IGUAL AL ORIGINAL)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  TextField(
                    controller: _userCtrl,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person), 
                      hintText: 'Usuario'
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _passCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock), 
                      hintText: 'Contraseña'
                    ),
                  ),
                  SizedBox(height: 40),
                  _loading
                      ? CircularProgressIndicator(color: AppTheme.kPrimaryColor)
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _doLogin,
                            child: Text(
                              "INICIAR SESIÓN", 
                              style: TextStyle(fontWeight: FontWeight.bold)
                            ),
                          ),
                        ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (_) => const RegisterPage())
                    ),
                    child: Text(
                      "Crear una cuenta nueva", 
                      style: TextStyle(color: AppTheme.kPrimaryColor)
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}