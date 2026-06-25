class Estante {
  final int idEstante;
  final String codigo;
  final String descripcion;

  Estante({
    required this.idEstante,
    required this.codigo,
    required this.descripcion,
  });

  factory Estante.fromJson(Map<String, dynamic> json) {
    return Estante(
      idEstante: json['id_estante'],
      codigo: json['codigo'],
      descripcion: json['descripcion'] ?? '',
    );
  }
}