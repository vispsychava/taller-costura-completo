import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const TallerCosturaApp());
}

class TallerCosturaApp extends StatelessWidget {
  const TallerCosturaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Costura Doña Tere',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const DashboardScreen(
        orders: [],
        reminders: [],
        shelves: [],
        
      ),
    );
  }
}