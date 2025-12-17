import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jualbeli_buku_bekas/core/constants/api_constants.dart';

class SupabaseService {
  SupabaseService._();
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: ApiConstants.supabaseUrl,
      anonKey: ApiConstants.supabaseAnonKey,
    );
  }
  static SupabaseClient get client => Supabase.instance.client;
}