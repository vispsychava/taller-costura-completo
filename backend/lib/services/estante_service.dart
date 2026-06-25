import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/estante.dart';

class EstanteService {
  final supabase = Supabase.instance.client;

  Future<List<Estante>> obtenerEstantes() async {
    final response =
        await supabase.from('estantes').select();

    return response
        .map<Estante>((json) => Estante.fromJson(json))
        .toList();
  }
}