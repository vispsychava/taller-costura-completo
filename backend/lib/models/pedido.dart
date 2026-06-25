class Pedido {
  final int? idPedido;
  final int idEstante;
  final int idPrenda;

  final String codigoPedido;
  final String nombreCliente;
  final String telefono;
  final String descripcion;

  final double precioTotal;
  final double anticipo;
  final double saldo;

  final String estadoPago;
  final String estadoPedido;

  Pedido({
    this.idPedido,
    required this.idEstante,
    required this.idPrenda,
    required this.codigoPedido,
    required this.nombreCliente,
    required this.telefono,
    required this.descripcion,
    required this.precioTotal,
    required this.anticipo,
    required this.saldo,
    required this.estadoPago,
    required this.estadoPedido,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      idPedido: json['id_pedido'],
      idEstante: json['id_estante'],
      idPrenda: json['id_prenda'],
      codigoPedido: json['codigo_pedido'],
      nombreCliente: json['nombre_cliente'],
      telefono: json['telefono'] ?? '',
      descripcion: json['descripcion'] ?? '',
      precioTotal: (json['precio_total'] ?? 0).toDouble(),
      anticipo: (json['anticipo'] ?? 0).toDouble(),
      saldo: (json['saldo'] ?? 0).toDouble(),
      estadoPago: json['estado_pago'] ?? 'Pendiente',
      estadoPedido: json['estado_pedido'] ?? 'Registrado',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_estante': idEstante,
      'id_prenda': idPrenda,
      'codigo_pedido': codigoPedido,
      'nombre_cliente': nombreCliente,
      'telefono': telefono,
      'descripcion': descripcion,
      'precio_total': precioTotal,
      'anticipo': anticipo,
      'saldo': saldo,
      'estado_pago': estadoPago,
      'estado_pedido': estadoPedido,
    };
  }
}