import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/prendas.dart';

class PrendaService {
  final supabase = Supabase.instance.client;

  Future<List<Prenda>> obtenerPrendas() async {
    final response =
        await supabase.from('prendas').select();

    return response
        .map<Prenda>((json) => Prenda.fromJson(json))
        .toList();
  }
}