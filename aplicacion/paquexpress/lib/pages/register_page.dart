import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../core/api.dart';
import '../core/theme.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _u = TextEditingController(), _p = TextEditingController(), _n = TextEditingController();
  bool _l = false;

  Future<void> _reg() async {
    setState(() => _l = true);
    try {
      final res = await http.post(
        Uri.parse('$apiEndpoint/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _u.text, 
          'password': _p.text, 
          'full_name': _n.text
        }),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('¡Éxito! Inicia sesión.'))
          );
          Navigator.pop(context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar'))
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión'))
      );
    } finally {
      if (mounted) setState(() => _l = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0, 
        foregroundColor: AppTheme.kPrimaryColor
      ),
      body: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Nueva Cuenta", 
              style: TextStyle(
                fontSize: 32, 
                fontWeight: FontWeight.bold, 
                color: AppTheme.kPrimaryColor
              ),
            ),
            Text(
              "Únete al equipo de logística", 
              style: TextStyle(fontSize: 16, color: Colors.grey)
            ),
            SizedBox(height: 40),
            TextField(
              controller: _u, 
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.account_circle), 
                hintText: 'Usuario'
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _n, 
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.badge), 
                hintText: 'Nombre Completo'
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _p, 
              obscureText: true, 
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.vpn_key), 
                hintText: 'Contraseña'
              ),
            ),
            Spacer(),
            _l 
                ? Center(child: CircularProgressIndicator()) 
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _reg, 
                      child: Text("REGISTRARSE")
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}