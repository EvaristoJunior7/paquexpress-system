import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api.dart';
import '../core/storage.dart';
import '../core/theme.dart';
import '../models/package_model.dart';

class DetailPage extends StatefulWidget {
  final PackageModel package;

  const DetailPage({super.key, required this.package});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  XFile? _photo;
  Uint8List? _bytes;
  bool _uploading = false;
  late LatLng _target;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _target = LatLng(widget.package.latitude, widget.package.longitude);
  }

  Future<void> _snap() async {
    try {
      final f = await _picker.pickImage(
        source: ImageSource.camera, 
        maxWidth: 800, 
        imageQuality: 50
      );
      if(f != null) {
        final b = await f.readAsBytes();
        setState(() { 
          _photo = f; 
          _bytes = b; 
        });
      }
    } catch (e) {
      // Fallback a galería
      final f = await _picker.pickImage(
        source: ImageSource.gallery, 
        maxWidth: 800
      );
      if(f != null) {
        final b = await f.readAsBytes();
        setState(() { 
          _photo = f; 
          _bytes = b; 
        });
      }
    }
  }

  Future<void> _send() async {
    if (_photo == null) {
      _msg('Falta la foto de evidencia', true);
      return;
    }
    
    setState(() => _uploading = true);
    try {
      final pos = await Geolocator.getCurrentPosition();
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        _msg('Error de autenticación', true);
        return;
      }
      
      // ✅ ACTUALIZADO: Con /packages/ para coincidir con la API modular
      var req = http.MultipartRequest(
        'POST', 
        Uri.parse('$apiEndpoint/packages/deliver/${widget.package.id}')
      );
      
      req.headers['Authorization'] = 'Bearer $token';
      req.fields['lat'] = pos.latitude.toString();
      req.fields['lon'] = pos.longitude.toString();
      
      // ✅ COMO EL ORIGINAL: Manejo simple de archivos
      if (kIsWeb) {
        req.files.add(http.MultipartFile.fromBytes(
          'file', 
          _bytes!, 
          filename: 'ev.jpg'  // Nombre simple como el original
        ));
      } else {
        req.files.add(await http.MultipartFile.fromPath(
          'file', 
          _photo!.path
        ));
      }

      final res = await req.send();
      
      if (res.statusCode == 200) {
        _msg('Entrega Exitosa', false);
        await Future.delayed(Duration(seconds: 1));
        if (mounted) Navigator.pop(context);
      } else {
        final errorBody = await res.stream.bytesToString();
        print('Error del servidor: ${res.statusCode} - $errorBody');
        _msg('Error en servidor: ${res.statusCode}', true);
      }
    } catch(e) {
      print('Error en entrega: $e');
      _msg('Error: $e', true);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _msg(String m, bool err) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(m), 
        backgroundColor: err ? Colors.red : Colors.green
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Mapa como fondo superior (45% de la pantalla)
          Positioned(
            top: 0, 
            left: 0, 
            right: 0, 
            height: MediaQuery.of(context).size.height * 0.45,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _target, 
                zoom: 16
              ),
              markers: {
                Marker(
                  markerId: MarkerId('dest'), 
                  position: _target
                )
              },
              myLocationEnabled: true,
            ),
          ),
          
          // 2. Botón flotante para volver
          Positioned(
            top: 40, 
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black), 
                onPressed: () => Navigator.pop(context)
              ),
            ),
          ),

          // 3. Panel de control deslizable (55% de la pantalla)
          DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.6,
            maxChildSize: 0.9,
            builder: (ctx, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12, 
                      blurRadius: 20, 
                      offset: Offset(0, -5)
                    )
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.all(24),
                  children: [
                    // Indicador de arrastre
                    Center(
                      child: Container(
                        width: 40, 
                        height: 5, 
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300, 
                          borderRadius: BorderRadius.circular(10)
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    
                    // Información del destinatario
                    Text(
                      "DESTINATARIO", 
                      style: TextStyle(
                        color: Colors.grey, 
                        fontSize: 12, 
                        letterSpacing: 1.5
                      ),
                    ),
                    Text(
                      widget.package.customerName, 
                      style: TextStyle(
                        fontSize: 24, 
                        fontWeight: FontWeight.bold, 
                        color: AppTheme.kPrimaryColor
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: AppTheme.kAccentColor, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.package.address, 
                            style: TextStyle(
                              fontSize: 16, 
                              color: Colors.grey.shade700
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    Divider(height: 40),
                    
                    // Sección de evidencia fotográfica
                    Text(
                      "EVIDENCIA FOTOGRÁFICA", 
                      style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                    SizedBox(height: 15),
                    GestureDetector(
                      onTap: _snap,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Color(0xFFF4F6F8),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _photo == null ? Colors.transparent : AppTheme.kAccentColor, 
                            width: 2
                          ),
                          image: _bytes != null 
                            ? DecorationImage(
                                image: MemoryImage(_bytes!), 
                                fit: BoxFit.cover
                              ) 
                            : null,
                        ),
                        child: _bytes == null 
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                                Text(
                                  "Toca para tomar foto", 
                                  style: TextStyle(color: Colors.grey)
                                ),
                              ],
                            )
                          : null,
                      ),
                    ),
                    
                    SizedBox(height: 30),
                    
                    // Botón de confirmación
                    _uploading 
                      ? Center(
                          child: CircularProgressIndicator(color: AppTheme.kAccentColor)
                        )
                      : ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.kAccentColor, 
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: _send,
                          icon: Icon(Icons.check_circle_outline),
                          label: Text("CONFIRMAR ENTREGA"),
                        )
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }
}