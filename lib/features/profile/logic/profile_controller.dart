import 'dart:io';
import 'package:flutter/material.dart';
import 'package:jualbeli_buku_bekas/models/user_model.dart';
import 'package:jualbeli_buku_bekas/services/auth_service.dart';
import 'package:jualbeli_buku_bekas/shared/widgets/custom_snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileController {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AuthService _authService = AuthService();

  Future<UserModel?> fetchUserProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      final Map<String, dynamic> data = response;
      data['email'] = user.email;

      return UserModel.fromJson(data);
    } catch (e) {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        return UserModel(
          id: user.id,
          email: user.email ?? '',
          fullName: user.userMetadata?['full_name'] ?? 'Pengguna',
        );
      }
      return null;
    }
  }

  Future<void> updateProfile(BuildContext context, {
    required String fullName,
    required String phoneNumber,
    required String address,
    File? imageFile,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      Map<String, dynamic> updates = {
        'id': user.id,
        'full_name': fullName,
        'phone_number': phoneNumber,
        'address': address,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (imageFile != null) {
        final fileExt = imageFile.path.split('.').last;
        final fileName = '${user.id}/avatar.$fileExt';
        await _supabase.storage.from('avatars').upload(
          fileName,
          imageFile,
          fileOptions: const FileOptions(upsert: true),
        );

        final imageUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);
        updates['avatar_url'] = imageUrl;
      }

      await _supabase.from('profiles').upsert(updates);

      await _supabase.auth.updateUser(
        UserAttributes(data: {'full_name': fullName}),
      );

      if (context.mounted) {
        CustomSnackbar.showSuccess(context, 'Profil berhasil diperbarui!');
        Navigator.pop(context, true); 
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.showError(context, 'Gagal update profil: $e');
      }
    }
  }

  Future<void> logout(BuildContext context) async {
    await _authService.signOut();
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }
}