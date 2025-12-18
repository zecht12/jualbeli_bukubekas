// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:jualbeli_buku_bekas/core/utils/currency_formatter.dart';
import 'package:jualbeli_buku_bekas/features/cart/logic/cart_controller.dart';
import 'package:jualbeli_buku_bekas/features/cart/presentation/pages/cart_page.dart';
import 'package:jualbeli_buku_bekas/features/chat/logic/chat_controller.dart';
import 'package:jualbeli_buku_bekas/features/chat/presentation/pages/chat_room_page.dart';
import 'package:jualbeli_buku_bekas/models/book_model.dart';
import 'package:jualbeli_buku_bekas/services/supabase_service.dart';
import 'package:jualbeli_buku_bekas/services/user_service.dart';
import 'package:jualbeli_buku_bekas/shared/widgets/custom_button.dart';
import 'package:jualbeli_buku_bekas/shared/widgets/custom_snackbar.dart';

class BookDetailPage extends StatefulWidget {
  final BookModel book;

  const BookDetailPage({super.key, required this.book});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  final CartController _cartController = CartController();
  final ChatController _chatController = ChatController();
  final UserService _userService = UserService();
  
  bool _isAddingToCart = false;
  bool _isOpeningChat = false;
  int _quantity = 1;

  void _incrementQuantity() {
    if (_quantity < widget.book.stock) {
      setState(() => _quantity++);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stok hanya tersedia ${widget.book.stock}')),
      );
    }
  }

  void _decrementQuantity() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  void _handleAddToCart() async {
    setState(() => _isAddingToCart = true);
    await _cartController.addToCart(context, widget.book.id, quantity: _quantity);
    if (!mounted) return;
    setState(() => _isAddingToCart = false);
    Navigator.push(context, MaterialPageRoute(builder: (context) => const CartPage()));
  }

  void _handleChatSeller() async {
    final myId = SupabaseService.client.auth.currentUser!.id;
    if (widget.book.userId == myId) {
      CustomSnackbar.showError(context, 'Ini adalah buku anda sendiri.');
      return;
    }
    setState(() => _isOpeningChat = true);
    final roomId = await _chatController.initiateChat(context, widget.book.userId);
    if (roomId == null) {
      if (mounted) setState(() => _isOpeningChat = false);
      return;
    }
    try {
      final sellerProfile = await _userService.getUserProfile(widget.book.userId);
      final sellerName = sellerProfile?['full_name'] ?? 'Penjual';
      if (!mounted) return;
      setState(() => _isOpeningChat = false);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChatRoomPage(roomId: roomId, otherUserName: sellerName)),
      );
    } catch (e) {
      if (mounted) setState(() => _isOpeningChat = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                widget.book.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.broken_image, size: 50)),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        CurrencyFormatter.toRupiah(widget.book.price),
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            widget.book.rating > 0 ? widget.book.rating.toString() : 'Baru',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  Text(
                    widget.book.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildChip(widget.book.category, Colors.blue.shade100, Colors.blue.shade800),
                      _buildChip(widget.book.condition, 
                        widget.book.condition == 'Baru' ? Colors.green.shade100 : Colors.orange.shade100,
                        widget.book.condition == 'Baru' ? Colors.green.shade800 : Colors.orange.shade800,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Jumlah:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(onPressed: _decrementQuantity, icon: const Icon(Icons.remove, size: 18)),
                            Text('$_quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            IconButton(onPressed: _incrementQuantity, icon: const Icon(Icons.add, size: 18)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const Divider(height: 32),
                  const Text('Deskripsi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    widget.book.description,
                    style: TextStyle(fontSize: 16, color: Colors.grey[800], height: 1.5),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isOpeningChat ? null : _handleChatSeller,
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: _isOpeningChat ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Chat Penjual'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: 'Beli Sekarang', 
                  isLoading: _isAddingToCart,
                  onPressed: _handleAddToCart,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Text(label, style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}