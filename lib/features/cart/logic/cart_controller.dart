import 'package:flutter/material.dart';
import 'package:jualbeli_buku_bekas/models/cart_item_model.dart';
import 'package:jualbeli_buku_bekas/services/order_service.dart';
import 'package:jualbeli_buku_bekas/shared/widgets/custom_snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartController {
  final SupabaseClient _supabase = Supabase.instance.client;
  final OrderService _orderService = OrderService();
  Future<List<CartItemModel>> fetchCartItems() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
          .from('cart_items')
          .select('*, books(*)') 
          .eq('user_id', userId);

      final List<dynamic> data = response;
      return data.map((json) => CartItemModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal memuat keranjang: $e');
    }
  }

  Future<void> addToCart(BuildContext context, String bookId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Silakan login terlebih dahulu');

      await _supabase.from('cart_items').insert({
        'user_id': userId,
        'book_id': bookId,
      });

      if (context.mounted) {
        CustomSnackbar.showSuccess(context, 'Buku masuk keranjang!');
      }
    } catch (e) {
      if (context.mounted) {
        if (e.toString().contains('duplicate key')) {
          CustomSnackbar.showError(context, 'Buku ini sudah ada di keranjang.');
        } else {
          CustomSnackbar.showError(context, 'Gagal menambah ke keranjang');
        }
      }
    }
  }

  Future<void> removeFromCart(BuildContext context, String cartItemId) async {
    try {
      await _supabase.from('cart_items').delete().eq('id', cartItemId);
      if (context.mounted) {
        CustomSnackbar.showSuccess(context, 'Item dihapus.');
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.showError(context, 'Gagal menghapus item.');
      }
    }
  }

  Future<void> checkout(BuildContext context, List<CartItemModel> items) async {
    try {
      if (items.isEmpty) throw Exception('Keranjang kosong');
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Sesi habis');

      int totalPrice = items.fold(0, (sum, item) => sum + (item.book.price * item.quantity));

      await _orderService.createOrder(
        userId: userId,
        totalPrice: totalPrice,
        items: items,
      );

      await _supabase.from('cart_items').delete().eq('user_id', userId);

      if (context.mounted) {
        CustomSnackbar.showSuccess(context, 'Pesanan berhasil dibuat!');
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.showError(context, 'Checkout gagal: $e');
      }
    }
  }
}