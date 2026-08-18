import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './screens/homeScreen.dart';
import './provider/MatchProvider.dart';
import './provider/UserProvider.dart';
import './services/dashboardService.dart';
import '../models/dashboard_data_models.dart';
import 'package:vsm_app/provider/player_dashboard_provider.dart';
import './provider/auth_provider.dart';

void main() async {
  // 1. Indique à Flutter d'attendre que le moteur soit prêt avant d'initialiser les liaisons
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => MatchProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardService()),
        ChangeNotifierProvider(create: (_) => PlayerDashboardProvider()),
      ],
      child: VSM_app(),
    ),
  );
}

class VSM_app extends StatefulWidget {
  const VSM_app({super.key});

  @override
  State<VSM_app> createState() => _VSM_appState();
}

class _VSM_appState extends State<VSM_app> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomeScreen());
  }
}
