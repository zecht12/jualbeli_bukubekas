import 'package:flutter/material.dart';
import 'package:jualbeli_buku_bekas/core/utils/currency_formatter.dart';
import 'package:jualbeli_buku_bekas/features/book/presentation/pages/edit_book_page.dart';
import 'package:jualbeli_buku_bekas/models/book_model.dart';
import 'package:jualbeli_buku_bekas/services/book_service.dart';
import 'package:jualbeli_buku_bekas/services/supabase_service.dart';
import 'package:jualbeli_buku_bekas/shared/widgets/loading_spinner.dart';

class MyBooksPage extends StatefulWidget {
  const MyBooksPage({super.key});

  @override
  State<MyBooksPage> createState() => _MyBooksPageState();
}

class _MyBooksPageState extends State<MyBooksPage> {
  final BookService _bookService = BookService();
  final String myId = SupabaseService.client.auth.currentUser!.id;
  
  bool _isLoading = true;
  List<BookModel> _myBooks = [];

  @override
  void initState() {
    super.initState();
    _loadMyBooks();
  }

  Future<void> _loadMyBooks() async {
    setState(() => _isLoading = true);
    try {
      final data = await _bookService.getMyBooks(myId);
      if (mounted) {
        setState(() {
          _myBooks = data.map((e) => BookModel.fromJson(e)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteBook(String bookId) async {
    try {
      await _bookService.deleteBook(bookId);
      _loadMyBooks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Buku berhasil dihapus')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal hapus: $e')),
        );
      }
    }
  }

  void _showDeleteDialog(String bookId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Buku?'),
        content: const Text('Buku ini akan dihapus permanen dari toko anda.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteBook(bookId);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produk Saya')),
      body: _isLoading
          ? const LoadingSpinner()
          : _myBooks.isEmpty
              ? const Center(child: Text('Anda belum menjual buku apapun'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _myBooks.length,
                  itemBuilder: (context, index) {
                    final book = _myBooks[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                book.imageUrl,
                                width: 60,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Container(color: Colors.grey, width: 60, height: 80),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text('Stok: ${book.stock}'),
                                  Text(CurrencyFormatter.toRupiah(book.price), style: TextStyle(color: Theme.of(context).primaryColor)),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditBookPage(book: book),
                                  ),
                                );
                                _loadMyBooks();
                              },
                              icon: const Icon(Icons.edit, color: Colors.blue),
                            ),
                            IconButton(
                              onPressed: () => _showDeleteDialog(book.id),
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}