import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jualbeli_buku_bekas/models/cart_item_model.dart';
import 'package:jualbeli_buku_bekas/services/supabase_service.dart';

class OrderService {
  final SupabaseClient _supabase = SupabaseService.client;

  Future<void> createOrder({
    required String userId,
    required int totalPrice,
    required List<CartItemModel> items,
    String? customOrderId,
    String? paymentUrl,
  }) async {
    try {
      if (items.isEmpty) {
        throw Exception('Keranjang belanja kosong. Tidak bisa checkout.');
      }

      final itemPertama = items.first;
      final String sellerId = itemPertama.book.userId;
      final String bookId = itemPertama.book.id;

      final data = {
        'user_id': userId,
        'seller_id': sellerId,
        'book_id': bookId, 
        'total_price': totalPrice,
        'status': 'MENUNGGU_PEMBAYARAN', 
        'is_reviewed': false,
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'items_summary': items.map((e) => '${e.book.title} (x${e.quantity})').join(', '),
      };

      if (customOrderId != null) {
        data['items_summary'] = '${data['items_summary']} (Ref: $customOrderId)';
      }
      if (paymentUrl != null) {
        data['payment_url'] = paymentUrl;
      }

      await _supabase.from('orders').insert(data);

      for (var item in items) {
        final bookData = await _supabase
            .from('books')
            .select('stock')
            .eq('id', item.book.id)
            .single();
        
        int currentStock = (bookData['stock'] as num).toInt();
        int newStock = currentStock - item.quantity;

        if (newStock < 0) newStock = 0;

        await _supabase.from('books').update({
          'stock': newStock,
        }).eq('id', item.book.id);
      }

    } catch (e) {
      throw Exception('Gagal membuat pesanan: $e');
    }
  }

  Future<void> submitReview({
    required String orderId,
    required String bookId,
    required String userId,
    required int rating,
    required String comment,
  }) async {
    try {
      await _supabase.from('reviews').insert({
        'book_id': bookId,
        'user_id': userId,
        'rating': rating,
        'comment': comment,
      });

      await _supabase.from('orders').update({
        'is_reviewed': true,
      }).eq('id', orderId);

      final reviews = await _supabase.from('reviews').select('rating').eq('book_id', bookId);
      final List data = reviews as List;
      
      if (data.isNotEmpty) {
        double total = 0;
        for (var r in data) {
          total += (r['rating'] as int);
        }
        double newRating = total / data.length;
        
        await _supabase.from('books').update({
          'rating': newRating,
        }).eq('id', bookId);
      }

    } catch (e) {
      throw Exception('Gagal mengirim ulasan: $e');
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _supabase.from('orders').update({
        'status': newStatus,
      }).eq('id', orderId);
    } catch (e) {
      throw Exception('Gagal update status: $e');
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
      throw Exception('Gagal mengambil riwayat: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getIncomingOrders(String sellerId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select()
          .eq('seller_id', sellerId)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Gagal mengambil pesanan masuk: $e');
    }
  }
}