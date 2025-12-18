// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:jualbeli_buku_bekas/core/utils/currency_formatter.dart';
import 'package:jualbeli_buku_bekas/features/order/logic/order_controller.dart';
import 'package:jualbeli_buku_bekas/features/payment/presentation/pages/payment_page.dart'; 
import 'package:jualbeli_buku_bekas/shared/widgets/custom_snackbar.dart';
import 'package:timeago/timeago.dart' as timeago;

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final OrderController _controller = OrderController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    timeago.setLocaleMessages('id', timeago.IdMessages());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(text: 'Pembelian Saya'),
            Tab(text: 'Pesanan Masuk'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OrdersList(
            fetchFunction: () => _controller.fetchMyOrders(context),
            isSellerView: false,
            controller: _controller,
          ),
          _OrdersList(
            fetchFunction: () => _controller.fetchIncomingOrders(context),
            isSellerView: true,
            controller: _controller,
          ),
        ],
      ),
    );
  }
}

class _OrdersList extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> Function() fetchFunction;
  final bool isSellerView;
  final OrderController controller;

  const _OrdersList({
    required this.fetchFunction,
    required this.isSellerView,
    required this.controller,
  });

  @override
  State<_OrdersList> createState() => _OrdersListState();
}

class _OrdersListState extends State<_OrdersList> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    final data = await widget.fetchFunction();
    
    if (!mounted) return;
    setState(() {
      _orders = data;
      _isLoading = false;
    });
  }

  void _handleStatusUpdate(String orderId, String newStatus) async {
    await widget.controller.updateOrderStatus(context, orderId, newStatus);
    _loadData(); 
  }

  void _showReviewDialog(String orderId, String? bookId) {
    if (bookId == null) {
      CustomSnackbar.showError(context, 'Data buku tidak valid');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _ReviewDialog(
        onSubmit: (rating, comment) async {
          final success = await widget.controller.submitReview(
            context,
            orderId: orderId,
            bookId: bookId,
            rating: rating,
            comment: comment,
          );
          if (success) _loadData(); 
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    
    if (_orders.isEmpty) {
      return Center(child: Text(widget.isSellerView ? 'Belum ada pesanan masuk' : 'Belum ada riwayat belanja'));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          return _OrderCard(
            order: order,
            isSellerView: widget.isSellerView,
            onUpdateStatus: _handleStatusUpdate,
            onRefresh: _loadData,
            onReview: () => _showReviewDialog(order['id'].toString(), order['book_id']?.toString()),
          );
        },
      ),
    );
  }
}

class _ReviewDialog extends StatefulWidget {
  final Function(int rating, String comment) onSubmit;

  const _ReviewDialog({required this.onSubmit});

  @override
  State<_ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<_ReviewDialog> {
  int _rating = 5;
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Beri Ulasan'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Bagaimana kualitas bukunya?'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                onPressed: () => setState(() => _rating = index + 1),
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 32,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              hintText: 'Tulis komentar anda...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            widget.onSubmit(_rating, _commentController.text);
          },
          child: const Text('Kirim'),
        ),
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final bool isSellerView;
  final Function(String id, String status) onUpdateStatus;
  final VoidCallback onRefresh;
  final VoidCallback onReview;

  const _OrderCard({
    required this.order,
    required this.isSellerView,
    required this.onUpdateStatus,
    required this.onRefresh,
    required this.onReview,
  });

  void _processPayment(BuildContext context, String? url) {
    if (url == null || url.isEmpty) {
      CustomSnackbar.showError(context, 'Link pembayaran kedaluwarsa.');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          paymentUrl: url, 
          onFinish: () {
            CustomSnackbar.showSuccess(context, 'Pembayaran berhasil!');
            onUpdateStatus(order['id'].toString(), 'DIKEMAS'); 
            onRefresh();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = order['status'] ?? 'DIPROSES';
    final date = DateTime.parse(order['created_at']).toLocal();
    final totalPrice = order['total_price'] ?? 0;
    final String? paymentUrl = order['payment_url'] as String?;
    final bool isReviewed = order['is_reviewed'] ?? false;
    final orderIdRaw = order['id'].toString();
    final orderIdDisplay = orderIdRaw.length > 8 
        ? orderIdRaw.substring(0, 8) 
        : orderIdRaw;

    Color statusColor;
    switch (status) {
      case 'SELESAI': statusColor = Colors.green; break;
      case 'DIKIRIM': statusColor = Colors.blue; break;
      case 'DIKEMAS': statusColor = Colors.orange; break;
      case 'MENUNGGU_PEMBAYARAN': statusColor = Colors.red; break;
      default: statusColor = Colors.grey;
    }

    final bool canPay = !isSellerView && status == 'MENUNGGU_PEMBAYARAN';
    final bool canReview = !isSellerView && status == 'SELESAI' && !isReviewed;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: canPay ? () => _processPayment(context, paymentUrl) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text('Order #$orderIdDisplay', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.5)),
                    ),
                    child: Text(status.replaceAll('_', ' '), style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(timeago.format(date, locale: 'id'), style: const TextStyle(color: Colors.grey, fontSize: 12), overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              
              const Divider(height: 24),
              Text(order['items_summary'] ?? '-', style: const TextStyle(fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Bayar', style: TextStyle(fontWeight: FontWeight.w500)),
                  Flexible(
                    child: Text(CurrencyFormatter.toRupiah(totalPrice), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),

              if (canPay) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _processPayment(context, paymentUrl),
                    icon: const Icon(Icons.payment, size: 18),
                    label: const Text('Bayar Sekarang'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                  ),
                ),
              ],

              if (canReview) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onReview,
                    icon: const Icon(Icons.star, size: 18, color: Colors.amber),
                    label: const Text('Beri Ulasan'),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.amber)),
                  ),
                ),
              ],
              
              if (!isSellerView && status == 'SELESAI' && isReviewed)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Center(child: Text('Pesanan Selesai & Sudah Diulas', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold))),
                ),

              if (isSellerView) ...[
                const Divider(height: 24),
                const Text('Update Status:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _StatusButton(label: 'DIKEMAS', isActive: status == 'DIKEMAS', onTap: () => onUpdateStatus(order['id'].toString(), 'DIKEMAS')),
                      const SizedBox(width: 8),
                      _StatusButton(label: 'DIKIRIM', isActive: status == 'DIKIRIM', onTap: () => onUpdateStatus(order['id'].toString(), 'DIKIRIM')),
                      const SizedBox(width: 8),
                      _StatusButton(label: 'SELESAI', isActive: status == 'SELESAI', onTap: () => onUpdateStatus(order['id'].toString(), 'SELESAI')),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _StatusButton({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isActive ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.grey[300] : Colors.white,
        foregroundColor: isActive ? Colors.grey : Colors.blue,
        elevation: 0,
        side: BorderSide(color: isActive ? Colors.transparent : Colors.blue),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        minimumSize: const Size(0, 32),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11)),
    );
  }
}