import 'package:flutter/material.dart';
import 'package:jualbeli_buku_bekas/services/order_service.dart';
import 'package:jualbeli_buku_bekas/services/supabase_service.dart';
import 'package:jualbeli_buku_bekas/shared/widgets/custom_snackbar.dart';

class OrderController {
  final OrderService _service = OrderService();

  Future<List<Map<String, dynamic>>> fetchMyOrders(BuildContext context) async {
    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user == null) return [];
      return await _service.getMyOrders(user.id);
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchIncomingOrders(BuildContext context) async {
    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user == null) return [];
      return await _service.getIncomingOrders(user.id);
    } catch (e) {
      return [];
    }
  }

  Future<void> updateOrderStatus(BuildContext context, String orderId, String newStatus) async {
    try {
      await _service.updateOrderStatus(orderId, newStatus);
      if (context.mounted) {
        CustomSnackbar.showSuccess(context, 'Status berhasil diubah menjadi $newStatus');
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.showError(context, 'Gagal update status: $e');
      }
    }
  }

  Future<bool> submitReview(BuildContext context, {
    required String orderId,
    required String bookId,
    required int rating,
    required String comment,
  }) async {
    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user == null) return false;

      await _service.submitReview(
        orderId: orderId,
        bookId: bookId,
        userId: user.id,
        rating: rating,
        comment: comment,
      );

      if (context.mounted) {
        CustomSnackbar.showSuccess(context, 'Terima kasih atas ulasan anda!');
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.showError(context, 'Gagal kirim ulasan: $e');
      }
      return false;
    }
  }
}