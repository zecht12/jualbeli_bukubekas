import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jualbeli_buku_bekas/models/book_model.dart';
import 'package:jualbeli_buku_bekas/services/book_service.dart';
import 'package:jualbeli_buku_bekas/services/storage_service.dart';
import 'package:jualbeli_buku_bekas/services/supabase_service.dart';
import 'package:jualbeli_buku_bekas/shared/widgets/custom_snackbar.dart';

class BookController {
  final BookService _bookService = BookService();
  final StorageService _storageService = StorageService();

  Future<List<BookModel>> fetchAllBooks() async {
    try {
      final data = await _bookService.getAllBooks();
      return data.map((json) => BookModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uploadBook(BuildContext context, {
    required String title,
    required String description,
    required String priceStr,
    required String category,
    required String condition,
    required String stockStr, 
    required XFile? imageFile,
  }) async {
    try {
      if (imageFile == null) throw Exception('Mohon sertakan foto buku.');
      
      final int? price = int.tryParse(priceStr);
      final int? stock = int.tryParse(stockStr);

      if (price == null || price <= 0) throw Exception('Harga tidak valid.');
      if (stock == null || stock < 1) throw Exception('Stok minimal 1.');
      final user = SupabaseService.client.auth.currentUser;
      if (user == null) throw Exception('Sesi habis. Silakan login kembali.');

      final String imageUrl = await _storageService.uploadBookImage(imageFile);

      await _bookService.addBook(
        title: title,
        description: description,
        price: price,
        imageUrl: imageUrl,
        userId: user.id,
        category: category,
        condition: condition,
        stock: stock,
      );

      if (context.mounted) {
        CustomSnackbar.showSuccess(context, 'Buku berhasil ditayangkan!');
      }
    } catch (e) {
      if (context.mounted) {
        String message = e.toString().replaceAll('Exception: ', '');
        CustomSnackbar.showError(context, message);
      }
      rethrow; 
    }
  }
}