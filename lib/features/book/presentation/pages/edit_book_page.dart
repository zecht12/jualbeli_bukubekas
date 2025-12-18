// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/foundation.dart'; // Untuk kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jualbeli_buku_bekas/core/utils/input_validator.dart';
import 'package:jualbeli_buku_bekas/models/book_model.dart';
import 'package:jualbeli_buku_bekas/services/book_service.dart';
import 'package:jualbeli_buku_bekas/services/storage_service.dart'; // Import Storage
import 'package:jualbeli_buku_bekas/shared/widgets/custom_button.dart';
import 'package:jualbeli_buku_bekas/shared/widgets/custom_text_field.dart';

class EditBookPage extends StatefulWidget {
  final BookModel book;

  const EditBookPage({super.key, required this.book});

  @override
  State<EditBookPage> createState() => _EditBookPageState();
}

class _EditBookPageState extends State<EditBookPage> {
  final _formKey = GlobalKey<FormState>();
  final BookService _bookService = BookService();
  final StorageService _storageService = StorageService();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  
  XFile? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book.title);
    _descController = TextEditingController(text: widget.book.description);
    _priceController = TextEditingController(text: widget.book.price.toString());
    _stockController = TextEditingController(text: widget.book.stock.toString());
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
    }
  }

  void _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        String? newImageUrl;

        if (_selectedImage != null) {
          newImageUrl = await _storageService.uploadBookImage(_selectedImage!);
        }

        await _bookService.updateBook(
          id: widget.book.id,
          title: _titleController.text,
          description: _descController.text,
          price: int.parse(_priceController.text),
          stock: int.parse(_stockController.text),
          imageUrl: newImageUrl,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Buku berhasil diperbarui')));
        Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider imageProvider;
    if (_selectedImage != null) {
      if (kIsWeb) {
        imageProvider = NetworkImage(_selectedImage!.path);
      } else {
        imageProvider = FileImage(File(_selectedImage!.path));
      }
    } else {
      imageProvider = NetworkImage(widget.book.imageUrl);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Produk')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[400]!),
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 40, color: Colors.white),
                            SizedBox(height: 8),
                            Text('Ketuk untuk ganti foto', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              CustomTextField(
                controller: _titleController,
                label: 'Judul Buku',
                validator: (v) => InputValidator.validateRequired(v, fieldName: 'Judul'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: CustomTextField(
                      controller: _priceController,
                      label: 'Harga',
                      keyboardType: TextInputType.number,
                      validator: (v) => InputValidator.validateRequired(v, fieldName: 'Harga'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _stockController,
                      label: 'Stok',
                      keyboardType: TextInputType.number,
                      validator: (v) => InputValidator.validateRequired(v, fieldName: 'Stok'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Deskripsi', border: OutlineInputBorder()),
                validator: (v) => InputValidator.validateRequired(v, fieldName: 'Deskripsi'),
              ),
              const SizedBox(height: 32),
              
              const Text(
                'Tips: Ubah stok menjadi 0 untuk menampilkan status "Habis".',
                style: TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              CustomButton(
                text: 'Simpan Perubahan',
                isLoading: _isLoading,
                onPressed: _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}