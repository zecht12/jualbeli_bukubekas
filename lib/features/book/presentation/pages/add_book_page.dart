// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jualbeli_buku_bekas/core/utils/input_validator.dart';
import 'package:jualbeli_buku_bekas/features/book/logic/book_controller.dart';
import 'package:jualbeli_buku_bekas/shared/widgets/custom_button.dart';
import 'package:jualbeli_buku_bekas/shared/widgets/custom_text_field.dart';

class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key});

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _controller = BookController();
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController(text: '1');

  XFile? _selectedImage;
  bool _isLoading = false;

  String _selectedCategory = 'Novel';
  String _selectedCondition = 'Bekas';

  final List<String> _categories = ['Novel', 'Komik', 'Pelajaran', 'Biografi', 'Bisnis', 'Teknologi', 'Lainnya'];
  final List<String> _conditions = ['Baru', 'Bekas'];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _selectedImage = pickedFile);
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wajib upload foto sampul'), backgroundColor: Colors.red));
        return;
      }

      setState(() => _isLoading = true);

      try {
        await _controller.uploadBook(
          context,
          title: _titleController.text,
          description: _descController.text,
          priceStr: _priceController.text,
          category: _selectedCategory,
          condition: _selectedCondition,
          stockStr: _stockController.text,
          imageFile: _selectedImage,
        );

        if (!mounted) return;
        setState(() => _isLoading = false);
        Navigator.pop(context);
      } catch (e) {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if (_selectedImage != null) {
      if (kIsWeb) imageProvider = NetworkImage(_selectedImage!.path);
      else imageProvider = FileImage(File(_selectedImage!.path));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Jual Buku')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
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
                    image: imageProvider != null ? DecorationImage(image: imageProvider, fit: BoxFit.cover) : null,
                  ),
                  child: _selectedImage == null
                      ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, size: 40, color: Colors.grey), SizedBox(height: 8), Text('Upload Foto Sampul', style: TextStyle(color: Colors.grey))])
                      : null,
                ),
              ),
              const SizedBox(height: 24),
              CustomTextField(controller: _titleController, label: 'Judul Buku', hint: 'Contoh: Laskar Pelangi', validator: (v) => InputValidator.validateRequired(v, fieldName: 'Judul')),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: CustomTextField(
                      controller: _priceController, 
                      label: 'Harga (Rp)', 
                      hint: '50000', 
                      keyboardType: TextInputType.number, 
                      validator: (v) => InputValidator.validateRequired(v, fieldName: 'Harga')
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: CustomTextField(
                      controller: _stockController, 
                      label: 'Stok', 
                      hint: '1', 
                      keyboardType: TextInputType.number,
                      validator: (v) => InputValidator.validateRequired(v, fieldName: 'Stok')
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()),
                items: _categories.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCondition,
                decoration: const InputDecoration(labelText: 'Kondisi', border: OutlineInputBorder()),
                items: _conditions.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                onChanged: (val) => setState(() => _selectedCondition = val!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 5,
                decoration: InputDecoration(labelText: 'Deskripsi', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                validator: (v) => InputValidator.validateRequired(v, fieldName: 'Deskripsi'),
              ),
              const SizedBox(height: 32),
              CustomButton(text: 'Tayangkan Iklan', isLoading: _isLoading, onPressed: _handleSubmit),
            ],
          ),
        ),
      ),
    );
  }
}