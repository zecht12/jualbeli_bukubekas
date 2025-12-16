import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jualbeli_buku_bekas/models/cart_item_model.dart';

class OrderService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> createOrder({
    required String userId,
    required int totalPrice,
    required List<CartItemModel> items,
  }) async {
    try {
      await _supabase.from('orders').insert({
        'user_id': userId,
        'total_price': totalPrice,
        'status': 'DIPROSES',
        'created_at': DateTime.now().toIso8601String(),
        'items_summary': items.map((e) => '${e.book.title} (x${e.quantity})').join(', '),
      });
    } catch (e) {
      throw Exception('Gagal membuat pesanan: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getMyOrders(String userId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Gagal mengambil riwayat pesanan: $e');
    }
  }
}