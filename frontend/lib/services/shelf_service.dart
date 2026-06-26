// lib/services/shelf_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/shelf.dart';

class ShelfService {
  final supabase = Supabase.instance.client;

  /// ✅ Obtener todos los estantes
  Future<List<Shelf>> obtenerEstantes() async {
    try {
      final response = await supabase
          .from('estantes')
          .select('''
            *,
            pedidos:pedidos(count)
          ''');

      List<Shelf> shelves = [];
      for (var json in response) {
        try {
          // Contar pedidos activos en este estante
          int garmentsCount = 0;
          if (json['pedidos'] != null) {
            // Si pedidos es un array, contar los elementos
            if (json['pedidos'] is List) {
              garmentsCount = (json['pedidos'] as List).length;
            } else if (json['pedidos'] is Map) {
              // Si es un objeto con count
              garmentsCount = json['pedidos']['count'] ?? 0;
            }
          }

          final shelf = Shelf(
            id: json['codigo_estante'] ?? '',
            capacity: json['capacidad'] ?? 10,
            garmentsCount: garmentsCount,
            status: _getStatusFromCount(garmentsCount, json['capacidad'] ?? 10),
            lastActivity: garmentsCount > 0 
                ? '${garmentsCount} prenda${garmentsCount > 1 ? 's' : ''} en almacenamiento'
                : 'Estante vacío',
          );
          shelves.add(shelf);
        } catch (e) {
          print('Error al mapear estante: $e');
        }
      }
      return shelves;
    } catch (e) {
      print('Error al obtener estantes: $e');
      return [];
    }
  }

  /// ✅ Crear un nuevo estante
  Future<void> crearEstante(String codigo, int capacidad) async {
    try {
      await supabase
          .from('estantes')
          .insert({
            'codigo_estante': codigo,
            'capacidad': capacidad,
          });
    } catch (e) {
      print('Error al crear estante: $e');
      rethrow;
    }
  }

  String _getStatusFromCount(int count, int capacity) {
    if (count == 0) return "Open";
    final percentage = count / capacity;
    if (percentage >= 1.0) return "Full";
    if (percentage >= 0.75) return "Near Full";
    return "Open";
  }
}