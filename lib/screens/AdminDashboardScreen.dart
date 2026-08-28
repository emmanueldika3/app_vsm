// lib/screens/admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsm_app/provider/admin_dashboard_provider.dart';
import 'package:vsm_app/widgets/Main_Layout.dart';

class AdminDashboardScreen extends StatefulWidget {
  final int initialIndex;

  const AdminDashboardScreen({super.key, this.initialIndex = 0});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Chargement initial des données d'administration si nécessaire
  }

  @override
  Widget build(BuildContext context) {
    // Le MainLayout gère la structure globale (AppBar, MemberProfileCard, BottomNav)
    return MainLayout(initialIndex: widget.initialIndex);
  }
}
