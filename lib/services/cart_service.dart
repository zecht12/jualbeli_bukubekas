import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jualbeli_buku_bekas/models/cart_item_model.dart';
import 'package:jualbeli_buku_bekas/services/supabase_service.dart';

class CartService {
  final SupabaseClient _supabase = SupabaseService.client;
  final String _tableName = 'cart_items'; 

  Future<void> addToCart(String userId, String bookId, {int quantity = 1}) async {
    try {
      final existingItem = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('book_id', bookId)
          .maybeSingle(); 

      if (existingItem != null) {
        final currentQty = existingItem['quantity'] as int;
        final itemId = existingItem['id'];

        await _supabase.from(_tableName).update({
          'quantity': currentQty + quantity,
        }).eq('id', itemId);
        
      } else {
        await _supabase.from(_tableName).insert({
          'user_id': userId,
          'book_id': bookId,
          'quantity': quantity,
        });
      }
    } catch (e) {
      throw Exception('Gagal menambah ke keranjang: $e');
    }
  }

  Future<List<CartItemModel>> getCartItems(String userId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('*, book:books(*)') 
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      final data = List<Map<String, dynamic>>.from(response);
      return data.map((json) => CartItemModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal memuat keranjang: $e');
    }
  }

  Future<void> removeCartItem(String cartItemId) async {
    try {
      await _supabase.from(_tableName).delete().eq('id', cartItemId);
    } catch (e) {
      throw Exception('Gagal menghapus item: $e');
    }
  }
}