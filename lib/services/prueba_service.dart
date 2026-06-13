import 'package:supabase_flutter/supabase_flutter.dart';

class PruebaService {
  final supabase = Supabase.instance.client;

  Future<List<dynamic>> obtenerDatos() async {
    return await supabase
        .from('prueba')
        .select();
  }
}