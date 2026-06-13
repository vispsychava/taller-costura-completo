import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pedido.dart';

class PedidoService {
  final supabase = Supabase.instance.client;

  Future<void> crearPedido(Pedido pedido) async {
    await supabase
        .from('pedidos')
        .insert(pedido.toJson());
  }

  Future<List<Pedido>> obtenerPedidos() async {
    final response = await supabase
        .from('pedidos')
        .select();

    return response
        .map<Pedido>((json) => Pedido.fromJson(json))
        .toList();
  }

  Future<void> eliminarPedido(int idPedido) async {
    await supabase
        .from('pedidos')
        .delete()
        .eq('id_pedido', idPedido);
  }

  Future<void> actualizarPedido(
      int idPedido,
      Pedido pedido,
      ) async {
    await supabase
        .from('pedidos')
        .update(pedido.toJson())
        .eq('id_pedido', idPedido);
  }

  Future<void> actualizarEstadoPedido(
      int idPedido,
      String estado,
      ) async {
    await supabase
        .from('pedidos')
        .update({
      'estado_pedido': estado
    })
        .eq('id_pedido', idPedido);
  }

  Future<void> actualizarEstadoPago(
      int idPedido,
      String estado,
      ) async {
    await supabase
        .from('pedidos')
        .update({
      'estado_pago': estado
    })
        .eq('id_pedido', idPedido);
  }
}