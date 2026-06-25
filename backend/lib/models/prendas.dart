class Prenda {
  final int idPrenda;
  final String nombre;

  Prenda({
    required this.idPrenda,
    required this.nombre,
  });

  factory Prenda.fromJson(Map<String, dynamic> json) {
    return Prenda(
      idPrenda: json['id_prenda'],
      nombre: json['nombre'],
    );
  }
}