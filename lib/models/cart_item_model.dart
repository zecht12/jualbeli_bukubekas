import 'package:jualbeli_buku_bekas/models/book_model.dart';

class CartItemModel {
  final String id;
  final BookModel book;
  final int quantity;

  CartItemModel({
    required this.id,
    required this.book,
    required this.quantity,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    var bookData = json['book'];

    if (bookData is List) {
      if (bookData.isEmpty) {
        throw Exception("Data buku kosong/terhapus (List Kosong)");
      }
      bookData = bookData.first;
    }
    
    if (bookData == null || bookData is! Map<String, dynamic>) {
      if (json['books'] != null) {
          bookData = json['books'];
          if (bookData is List) {
            if (bookData.isEmpty) throw Exception("Data buku kosong (books list empty)");
            bookData = bookData.first;
          }
      } else {
          throw Exception("Data buku tidak ditemukan atau format salah. Received: $bookData");
      }
    }

    return CartItemModel(
      id: json['id'].toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      book: BookModel.fromJson(bookData),
    );
  }
}