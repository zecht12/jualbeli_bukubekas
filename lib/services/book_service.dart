import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jualbeli_buku_bekas/services/supabase_service.dart';

class BookService {
  final SupabaseClient _supabase = SupabaseService.client;
  final String _table = 'books';

  Future<List<Map<String, dynamic>>> getAllBooks() async {
    try {
      final response = await _supabase
          .from(_table)
          .select()
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Gagal mengambil data buku: $e');
    }
  }

  Future<void> addBook({
    required String title,
    required String description,
    required int price,
    required String imageUrl,
    required String userId,
    required String category,
    required String condition,
    required int stock,
  }) async {
    try {
      await _supabase.from(_table).insert({
        'title': title,
        'description': description,
        'price': price,
        'image_url': imageUrl,
        'user_id': userId,
        'category': category,
        'condition': condition,
        'stock': stock,
        'rating': 0.0,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Gagal upload buku: $e');
    }
  }

  Future<void> updateBook({
    required String id,
    String? title,
    String? description,
    int? price,
    int? stock,
    String? imageUrl,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };

      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (price != null) updates['price'] = price;
      if (stock != null) updates['stock'] = stock; // Update stok
      if (imageUrl != null) updates['image_url'] = imageUrl;

      await _supabase.from(_table).update(updates).eq('id', id);
    } catch (e) {
      throw Exception('Gagal memperbarui buku: $e');
    }
  }

  Future<void> deleteBook(String id) async {
    try {
      await _supabase.from(_table).delete().eq('id', id);
    } catch (e) {
      throw Exception('Gagal menghapus buku: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getMyBooks(String userId) async {
    try {
      final response = await _supabase
          .from(_table)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Gagal mengambil buku saya: $e');
    }
  }
}