import 'package:image_picker/image_picker.dart';
import 'package:jualbeli_buku_bekas/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _supabase = SupabaseService.client;
  
  final String _bucket = 'book_covers'; 

  Future<String> uploadBookImage(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      
      final fileExt = imageFile.name.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final path = 'uploads/$fileName';

      await _supabase.storage.from(_bucket).uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(
          contentType: 'image/jpeg', 
          upsert: false
        ),
      );

      final String publicUrl = _supabase.storage.from(_bucket).getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      throw Exception('Gagal upload gambar: $e');
    }
  }
}