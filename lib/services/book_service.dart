import 'package:supabase_flutter/supabase_flutter.dart';

class BookService {
  final SupabaseClient _supabase = Supabase.instance.client;
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

  Future<Map<String, dynamic>> getBookById(String id) async {
    try {
      final response = await _supabase
          .from(_table)
          .select()
          .eq('id', id)
          .single();
      
      return response;
    } catch (e) {
      throw Exception('Buku tidak ditemukan');
    }
  }

  Future<List<Map<String, dynamic>>> getBooksByUserId(String userId) async {
    try {
      final response = await _supabase
          .from(_table)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Gagal memuat buku anda: $e');
    }
  }

  Future<void> addBook({
    required String title,
    required String description,
    required int price,
    required String imageUrl,
    required String userId,
  }) async {
    try {
      await _supabase.from(_table).insert({
        'title': title,
        'description': description,
        'price': price,
        'image_url': imageUrl,
        'user_id': userId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Gagal upload buku: $e');
    }
  }

  Future<void> updateBook({
    required String id,
    required String title,
    required String description,
    required int price,
    String? imageUrl,
  }) async {
    try {
      final updates = {
        'title': title,
        'description': description,
        'price': price,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (imageUrl != null) {
        updates['image_url'] = imageUrl;
      }

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

  Future<List<Map<String, dynamic>>> searchBooks(String query) async {
    try {
      final response = await _supabase
          .from(_table)
          .select()
          .ilike('title', '%$query%');
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Gagal mencari buku: $e');
    }
  }
}