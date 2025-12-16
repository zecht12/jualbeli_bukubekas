import 'package:jualbeli_buku_bekas/models/book_model.dart';
import 'package:jualbeli_buku_bekas/services/book_service.dart';

class HomeController {
  final BookService _bookService = BookService();
  Future<List<BookModel>> fetchBooks() async {
    try {
      final data = await _bookService.getAllBooks();
      return data.map((json) => BookModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal memuat buku: $e');
    }
  }
}