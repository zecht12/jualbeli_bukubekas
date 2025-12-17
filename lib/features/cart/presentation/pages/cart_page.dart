// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:jualbeli_buku_bekas/core/utils/currency_formatter.dart';
import 'package:jualbeli_buku_bekas/features/cart/logic/cart_controller.dart';
import 'package:jualbeli_buku_bekas/features/cart/presentation/widget/cart_item_tile.dart';
import 'package:jualbeli_buku_bekas/models/cart_item_model.dart';
import 'package:jualbeli_buku_bekas/shared/widgets/custom_button.dart';
import 'package:jualbeli_buku_bekas/shared/widgets/loading_spinner.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartController _controller = CartController();
  
  bool _isLoading = true;
  bool _isCheckingOut = false;
  List<CartItemModel> _items = [];

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      final data = await _controller.fetchCartItems();
      if (!mounted) return;

      setState(() {
        _items = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeItem(String id) async {
    await _controller.removeFromCart(context, id);
    if (!mounted) return;
    
    _loadCart();
  }

  Future<void> _handleCheckout() async {
    setState(() => _isCheckingOut = true);
    
    await _controller.checkout(context, _items);

    if (!mounted) return;

    setState(() => _isCheckingOut = false);
    _loadCart();
  }

  int get _totalPrice {
    return _items.fold(0, (sum, item) => sum + item.book.price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Belanja'),
      ),
      body: _isLoading
          ? const LoadingSpinner()
          : _items.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadCart,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return CartItemTile(
                        item: item,
                        onRemove: () => _removeItem(item.id),
                      );
                    },
                  ),
                ),

      bottomNavigationBar: _items.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Pembayaran:',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          CurrencyFormatter.toRupiah(_totalPrice),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Checkout Sekarang',
                      isLoading: _isCheckingOut,
                      onPressed: _handleCheckout,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Keranjang kamu kosong',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Yuk cari buku favoritmu sekarang!',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Silakan klik tab Beranda untuk belanja')),
                );
              }
            },
            child: const Text('Mulai Belanja'),
          ),
        ],
      ),
    );
  }
}