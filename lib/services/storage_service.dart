import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _bucket = 'book_covers'; 

  Future<String> uploadBookImage(File imageFile) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      final path = 'uploads/$fileName';

      await _supabase.storage.from(_bucket).upload(
        path,
        imageFile,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      final String publicUrl = _supabase.storage.from(_bucket).getPublicUrl(path);
      
      return publicUrl;
    } catch (e) {
      throw Exception('Gagal upload gambar ke bucket $_bucket: $e');
    }
  }
}