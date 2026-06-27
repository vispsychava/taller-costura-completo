// lib/services/order_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart';
import '../models/measurements.dart';

class OrderService {
  final supabase = Supabase.instance.client;

  /// ✅ Crear un nuevo pedido
  Future<Map<String, dynamic>> crearPedido(Order order) async {
    try {
      // Obtener el ID del estante por su código
      final shelfResponse = await supabase
          .from('estantes')
          .select('id_estante')
          .eq('codigo_estante', order.shelfAssignment)
          .maybeSingle();

      if (shelfResponse == null) {
        throw Exception('Estante no encontrado: ${order.shelfAssignment}');
      }

      final idEstante = shelfResponse['id_estante'];

      // Obtener el ID de la prenda por su nombre
      final prendaResponse = await supabase
          .from('prendas')
          .select('id_prenda')
          .eq('nombre', order.type)
          .maybeSingle();

      if (prendaResponse == null) {
        // Si no existe, crear la prenda
        final newPrenda = await supabase
            .from('prendas')
            .insert({
              'nombre': order.type,
              'descripcion': order.description,
            })
            .select()
            .single();
        final idPrenda = newPrenda['id_prenda'];
      }

      final idPrenda = prendaResponse?['id_prenda'];

      // Crear el mapa para insertar
      final data = {
        'id_estante': idEstante,
        'id_prenda': idPrenda,
        'codigo_pedido': order.id,
        'nombre_cliente': order.clientName,
        'telefono': order.clientPhone,
        'descripcion': order.description,
        'precio_total': order.totalAmount,
        'anticipo': order.advancePaid,
        'saldo': order.balanceDue,
        'estado_pago': order.balanceDue == 0 ? 'Pagado' : 'Pendiente',
        'estado_pedido': order.status,
        'fecha_entrega': order.expectedDeliveryDate,
      };

      final response = await supabase
          .from('pedidos')
          .insert(data)
          .select()
          .single();

      return response;
    } catch (e) {
      print('Error al crear pedido: $e');
      rethrow;
    }
  }

  /// ✅ Obtener todos los pedidos
  Future<List<Order>> obtenerPedidos() async {
    try {
      final response = await supabase
          .from('pedidos')
          .select('''
            *,
            estantes(id_estante, codigo_estante, capacidad),
            prendas(id_prenda, nombre, descripcion)
          ''');

      List<Order> orders = [];
      for (var json in response) {
        try {
          final order = _mapToOrder(json);
          orders.add(order);
        } catch (e) {
          print('Error al mapear pedido: $e');
        }
      }
      return orders;
    } catch (e) {
      print('Error al obtener pedidos: $e');
      return [];
    }
  }

  /// ✅ Actualizar un pedido
  Future<void> actualizarPedido(Order order) async {
    try {
      final data = {
        'nombre_cliente': order.clientName,
        'telefono': order.clientPhone,
        'descripcion': order.description,
        'precio_total': order.totalAmount,
        'anticipo': order.advancePaid,
        'saldo': order.balanceDue,
        'estado_pago': order.balanceDue == 0 ? 'Pagado' : 'Pendiente',
        'estado_pedido': order.status,
        'fecha_entrega': order.expectedDeliveryDate,
      };

      await supabase
          .from('pedidos')
          .update(data)
          .eq('codigo_pedido', order.id);
    } catch (e) {
      print('Error al actualizar pedido: $e');
      rethrow;
    }
  }

  /// ✅ Actualizar estado de un pedido
  Future<void> actualizarEstadoPedido(String orderId, String nuevoEstado) async {
    try {
      await supabase
          .from('pedidos')
          .update({
            'estado_pedido': nuevoEstado,
          })
          .eq('codigo_pedido', orderId);
    } catch (e) {
      print('Error al actualizar estado: $e');
      rethrow;
    }
  }

  /// ✅ Actualizar estado de pago
  Future<void> actualizarEstadoPago(String orderId, double nuevoSaldo) async {
    try {
      final estadoPago = nuevoSaldo == 0 ? 'Pagado' : 'Pendiente';
      await supabase
          .from('pedidos')
          .update({
            'saldo': nuevoSaldo,
            'estado_pago': estadoPago,
          })
          .eq('codigo_pedido', orderId);
    } catch (e) {
      print('Error al actualizar pago: $e');
      rethrow;
    }
  }

  /// ✅ Eliminar un pedido
  Future<void> eliminarPedido(String orderId) async {
    try {
      await supabase
          .from('pedidos')
          .delete()
          .eq('codigo_pedido', orderId);
    } catch (e) {
      print('Error al eliminar pedido: $e');
      rethrow;
    }
  }

  /// ✅ Mapear JSON a Order (frontend)
  Order _mapToOrder(Map<String, dynamic> json) {
    // Obtener el código del estante
    String shelfCode = '';
    if (json['estantes'] != null) {
      shelfCode = json['estantes']['codigo_estante'] ?? '';
    }

    // Obtener el nombre de la prenda
    String prendaNombre = '';
    if (json['prendas'] != null) {
      prendaNombre = json['prendas']['nombre'] ?? '';
    }

    // Parsear fecha de entrega
    String deliveryDate = json['fecha_entrega'] ?? '';
    if (deliveryDate.isEmpty) {
      final now = DateTime.now();
      deliveryDate = '${now.day}/${now.month}/${now.year}';
    }

    return Order(
      id: json['codigo_pedido'] ?? '',
      clientName: json['nombre_cliente'] ?? '',
      clientPhone: json['telefono'] ?? '',
      clientEmail: json['email'] ?? '',
      clientAvatar: 'https://i.pravatar.cc/150?img=1',
      title: prendaNombre.isNotEmpty ? '$prendaNombre - ${json['nombre_cliente']}' : 'Pedido',
      description: json['descripcion'] ?? '',
      type: prendaNombre,
      size: 'Talla única',
      status: json['estado_pedido'] ?? 'Sin empezar',
      statusDate: json['fecha_creacion'] ?? DateTime.now().toIso8601String(),
      expectedDeliveryDate: deliveryDate,
      totalAmount: (json['precio_total'] ?? 0).toDouble(),
      advancePaid: (json['anticipo'] ?? 0).toDouble(),
      balanceDue: (json['saldo'] ?? 0).toDouble(),
      shelfAssignment: shelfCode,
      measurements: Measurements.empty(),
      progressNotes: [],
      activityHistory: [],
      priority: 'Media',
    );
  }
}