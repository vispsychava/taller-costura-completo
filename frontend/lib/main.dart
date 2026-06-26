import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:taller_costura_flutter/services/supabase_service.dart';
import 'screens/dashboard_screen.dart';

import 'models/order.dart';      
import 'models/reminder.dart';   
import 'models/shelf.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://lckwfjszggnioczjfyxm.supabase.co',
    publishableKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imxja3dmanN6Z2duaW9jempmeXhtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEyODkzOTUsImV4cCI6MjA5Njg2NTM5NX0.8nV7pQPOosjPX4RyjYZxgVfyMqm9Rsjeaa8VO9ANIco',
  );

  runApp(const TallerCosturaApp());
}

class TallerCosturaApp extends StatelessWidget {
  const TallerCosturaApp({super.key});

  static final supabaseService = SupabaseService();


  Future<Map<String, List<dynamic>>> _cargarDatos() async {
    final listas = await Future.wait([
      supabaseService.obtenerOrdenes(),        // listas[0]
      supabaseService.obtenerRecordatorios(),  // listas[1]
      supabaseService.obtenerEstantes(),       // listas[2]
    ]);

    return {
      'orders': listas[0],
      'reminders': listas[1],
      'shelves': listas[2],
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Costura Doña Tere',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: FutureBuilder<Map<String, List<dynamic>>>(
        future: _cargarDatos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator(color: Colors.indigo)),
            );
          }

          if (snapshot.hasError) {
            return const Scaffold(
              body: Center(child: Text('Error al conectar con la base de datos')),
            );
          }

          final datos = snapshot.data!;
          return DashboardScreen(
            // Hacemos un cast rápido a sus tipos correspondientes
            orders: List<Order>.from(datos['orders']!),
            reminders: List<Reminder>.from(datos['reminders']!),
            shelves: List<Shelf>.from(datos['shelves']!),
          );
        },
      ),
    );
  }
}