import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jualbeli_buku_bekas/services/supabase_service.dart';

class UserService {
  final SupabaseClient _supabase = SupabaseService.client;

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUserProfile({
    required String userId,
    required String fullName,
    required String phoneNumber,
    required String address,
    String? avatarUrl,
  }) async {
    try {
      final updates = {
        'id': userId,
        'full_name': fullName,
        'phone_number': phoneNumber,
        'address': address,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };

      if (avatarUrl != null) {
        updates['avatar_url'] = avatarUrl;
      }

      await _supabase.from('profiles').upsert(updates);
    } catch (e) {
      throw Exception('Gagal update profil: $e');
    }
  }
}