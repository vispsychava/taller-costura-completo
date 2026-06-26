import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart'; 
import '../models/reminder.dart';
import '../models/shelf.dart';
import '../models/measurements.dart';
import '../models/progress_note.dart';
import '../models/activity_item.dart';

class SupabaseService {
  final _supabase = Supabase.instance.client;


  Future<List<Order>> obtenerOrdenes() async {
    try {
      final data = await _supabase.from('pedidos').select();
      
      return (data as List).map((json) {
        return Order(
          id: json['id_pedido']?.toString() ?? '0',
          type: json['estado_pedido'] ?? 'General',
          title: json['codigo_pedido'] ?? 'Pedido',
          description: json['descripcion'] ?? '',
          size: 'Estándar',
          status: json['estado_pedido'] ?? 'Pendiente',
          statusDate: json['fecha_registro'] ?? '', 
          expectedDeliveryDate: json['fecha_entrega'] ?? '',
          totalAmount: (json['precio_total'] as num?)?.toDouble() ?? 0.0, 
          advancePaid: (json['anticipo'] as num?)?.toDouble() ?? 0.0,    
          balanceDue: (json['saldo'] as num?)?.toDouble() ?? 0.0,        
          shelfAssignment: json['id_estante']?.toString() ?? 'Sin estante',
          measurements: Measurements.empty(), 
          progressNotes: <ProgressNote>[], 
          activityHistory: <ActivityItem>[], 
          priority: 'Media',          
          clientName: json['nombre_cliente'] ?? '',
          clientEmail: '', 
          clientAvatar: '', 
          clientPhone: json['telefono'] ?? '',
        );
      }).toList();
    } catch (e) {
      throw Exception('Fallo en obtenerOrdenes: $e');
    }
  }

  
  Future<List<Reminder>> obtenerRecordatorios() async {
    return []; 
  }

  Future<List<Shelf>> obtenerEstantes() async {
    try {
      final data = await _supabase.from('estantes').select();
      
      return (data as List).map((json) {
        return Shelf(
          id: json['id_estante']?.toString() ?? '0',
          status: json['descripcion'] ?? 'Sin descripción',
          garmentsCount: 0, 
          capacity: 10, 
          lastActivity: json['codigo'] ?? '', 
        );
      }).toList();
    } catch (e) {
      throw Exception('Fallo en obtenerEstantes: $e');
    }
  }

  
  Future<bool> insertarEstante(Shelf estante) async {
    try {
      await _supabase.from('estantes').insert({
       
        'id_estante': int.tryParse(estante.id),
        'descripcion': estante.status, 
        'codigo': estante.lastActivity,
      });
      return true; 
    } catch (e) {
      print(' Error al insertar estante en Supabase: $e');
      return false;
    }
  }


  Future<bool> insertarPedido(Map<String, dynamic> orderMap) async {
    try {
      await _supabase.from('pedidos').insert({
        'codigo_pedido': orderMap['id'],
        'nombre_cliente': orderMap['clientName'],
        'telefono': orderMap['clientPhone'],
        'descripcion': orderMap['description'],
        'precio_total': orderMap['totalAmount'],
        'anticipo': orderMap['advancePaid'],
        'saldo': orderMap['balanceDue'],
        'estado_pedido': orderMap['status'],
        'fecha_registro': orderMap['statusDate'],
        'fecha_entrega': orderMap['expectedDeliveryDate'].toString().substring(0, 10),
        'id_estante': int.tryParse(orderMap['shelfAssignment'].toString()),
      });
      return true;
    } catch (e) {
      print('Fatal Error: $e');
      return false;
    }
  }
}