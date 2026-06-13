import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://lckwfjszggnioczjfyxm.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imxja3dmanN6Z2duaW9jempmeXhtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEyODkzOTUsImV4cCI6MjA5Njg2NTM5NX0.8nV7pQPOosjPX4RyjYZxgVfyMqm9Rsjeaa8VO9ANIco',
    );
  }
}
//TallerCostura63 contraseña del proyecto de supabase