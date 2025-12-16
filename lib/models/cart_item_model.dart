import 'package:jualbeli_buku_bekas/models/book_model.dart';

class CartItemModel {
  final String id;
  final BookModel book;
  final int quantity;

  CartItemModel({
    required this.id,
    required this.book,
    this.quantity = 1,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'].toString(),
      book: BookModel.fromJson(json['books']), 
      quantity: json['quantity'] ?? 1,
    );
  }

  int get subTotal => book.price * quantity;
}