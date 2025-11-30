import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../core/api.dart';
import '../core/storage.dart';
import '../core/theme.dart';
import '../models/package_model.dart';
import 'detail_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<PackageModel> packages = [];
  bool loading = true;

  Future<void> fetchPackages() async {
    final token = await Storage.token;
    if (token == null) return _logout();

    try {
      final url = Uri.parse("$apiEndpoint/packages");
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          packages = data.map((e) => PackageModel.fromJson(e)).toList();
          loading = false;
        });
      } else {
        _logout();
      }
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Future<void> _logout() async {
    await Storage.clear();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPackages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // SliverAppBar elegante (como en el original)
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            backgroundColor: AppTheme.kPrimaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(left: 20, bottom: 20),
              title: Text(
                "Mis Entregas", 
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20,)
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.kPrimaryColor, Color(0xFF2C2C40)]
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.refresh, color: Colors.white70), 
                onPressed: fetchPackages
              ),
              IconButton(
                icon: Icon(Icons.logout, color: AppTheme.kAccentColor), 
                onPressed: _logout
              ),
            ],
          ),
          
          // Contenido de la lista
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: loading 
              ? SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator())
                )
              : packages.isEmpty
                ? SliverFillRemaining(child: _emptyState())
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _buildPackageCard(packages[i]),
                      childCount: packages.length,
                    ),
                  ),
          )
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.done_all, size: 80, color: Colors.grey.shade300),
          SizedBox(height: 16),
          Text(
            "Todo limpio por hoy", 
            style: TextStyle(color: Colors.grey, fontSize: 16)
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(PackageModel pkg) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.kBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.kBorderRadius),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailPage(package: pkg),
              ),
            ).then((_) => fetchPackages());
          },
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                // Icono decorativo
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFE0E5EC),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined, 
                    color: AppTheme.kPrimaryColor
                  ),
                ),
                SizedBox(width: 15),
                
                // Información del paquete
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pkg.trackingNumber,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.kPrimaryColor,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        pkg.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                
                // Flecha indicadora
                Icon(
                  Icons.arrow_forward_ios_rounded, 
                  size: 16, 
                  color: Colors.grey.shade300
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}