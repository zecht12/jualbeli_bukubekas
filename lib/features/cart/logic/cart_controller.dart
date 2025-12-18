// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:jualbeli_buku_bekas/features/payment/presentation/pages/payment_page.dart';
import 'package:jualbeli_buku_bekas/models/cart_item_model.dart';
import 'package:jualbeli_buku_bekas/services/cart_service.dart';
import 'package:jualbeli_buku_bekas/services/midtrans_service.dart';
import 'package:jualbeli_buku_bekas/services/order_service.dart';
import 'package:jualbeli_buku_bekas/services/supabase_service.dart';
import 'package:jualbeli_buku_bekas/services/user_service.dart';
import 'package:jualbeli_buku_bekas/shared/widgets/custom_snackbar.dart';

class CartController {
  final CartService _cartService = CartService();
  final OrderService _orderService = OrderService();
  final MidtransService _midtransService = MidtransService();
  final UserService _userService = UserService();

  Future<List<CartItemModel>> fetchCartItems() async {
    try {
      final userId = SupabaseService.client.auth.currentUser?.id;
      if (userId == null) return [];
      return await _cartService.getCartItems(userId);
    } catch (e) {
      debugPrint('Error fetch cart: $e');
      return [];
    }
  }

  Future<void> addToCart(BuildContext context, String bookId, {int quantity = 1}) async {
    try {
      final userId = SupabaseService.client.auth.currentUser?.id;
      if (userId == null) {
        CustomSnackbar.showError(context, 'Silakan login terlebih dahulu');
        return;
      }
      await _cartService.addToCart(userId, bookId, quantity: quantity);
      
      if (context.mounted) {
        CustomSnackbar.showSuccess(context, 'Buku masuk keranjang!');
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.showError(context, 'Gagal tambah ke keranjang: $e');
      }
    }
  }

  Future<void> removeFromCart(BuildContext context, String itemId) async {
    try {
      await _cartService.removeCartItem(itemId);
      if (context.mounted) {
        CustomSnackbar.showSuccess(context, 'Item dihapus');
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.showError(context, 'Gagal hapus item');
      }
    }
  }

  Future<void> checkout(BuildContext context, List<CartItemModel> items) async {
    if (items.isEmpty) {
      CustomSnackbar.showError(context, 'Keranjang kosong');
      return;
    }

    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user == null) return;
      final userProfile = await _userService.getUserProfile(user.id);
      final customerName = userProfile?['full_name'] ?? 'Pelanggan';
      final customerPhone = userProfile?['phone_number'] ?? '08123456789';
      final customerEmail = user.email ?? 'no-email@example.com';

      final int totalPrice = items.fold(0, (sum, item) => sum + (item.book.price * item.quantity));
      final String uniqueOrderId = 'ORDER-${DateTime.now().millisecondsSinceEpoch}';

      final String paymentUrl = await _midtransService.getPaymentUrl(
        orderId: uniqueOrderId,
        grossAmount: totalPrice,
        customerName: customerName,
        customerEmail: customerEmail,
        customerPhone: customerPhone,
      );

      await _orderService.createOrder(
        userId: user.id,
        totalPrice: totalPrice,
        items: items,
        customOrderId: uniqueOrderId,
        paymentUrl: paymentUrl, 
      );

      for (var item in items) {
        await _cartService.removeCartItem(item.id);
      }

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentPage(
              paymentUrl: paymentUrl,
              onFinish: () async {
                CustomSnackbar.showSuccess(context, 'Pembayaran berhasil diproses!');
                try {
                  final orderData = await SupabaseService.client
                      .from('orders')
                      .select('id')
                      .eq('payment_url', paymentUrl)
                      .single();
                  
                  if (orderData != null) {
                    await _orderService.updateOrderStatus(orderData['id'].toString(), 'DIKEMAS');
                  }
                } catch (e) {
                  debugPrint("Gagal update status otomatis: $e");
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.showError(context, 'Gagal checkout: ${e.toString()}');
      }
    }
  }
}