// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HalamanTambahBuku extends StatefulWidget {
  const HalamanTambahBuku({super.key});

  @override
  _HalamanTambahBukuState createState() => _HalamanTambahBukuState();
}

class _HalamanTambahBukuState extends State<HalamanTambahBuku> {
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _coverController = TextEditingController();
  final TextEditingController _penulisController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _jumlahHalamanController = TextEditingController();
  final TextEditingController _tahunPenggunaanController = TextEditingController();
  final TextEditingController _jumlahBukuController = TextEditingController();

  String _selectedKategori = 'Fiksi';
  final List<String> _kategoriOptions = ['Fiksi', 'Non-Fiksi', 'Komik', 'Sejarah', 'Biografi'];
  bool _isLoading = false;

  Future<void> _addBook() async {
    setState(() {
      _isLoading = true;
    });
    CollectionReference books = FirebaseFirestore.instance.collection('books');

    String status = int.parse(_jumlahBukuController.text) > 0 ? 'ready' : 'terjual';

    try {
      await books.add({
        'judul': _judulController.text,
        'cover': _coverController.text,
        'penulis': _penulisController.text,
        'harga': double.parse(_hargaController.text),
        'jumlah_halaman': int.parse(_jumlahHalamanController.text),
        'tahun_penggunaan': int.parse(_tahunPenggunaanController.text),
        'kategori': _selectedKategori,
        'jumlah_buku': int.parse(_jumlahBukuController.text),
        'status': status,
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Buku berhasil ditambahkan')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add book: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Buku')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                TextField(
                  controller: _judulController,
                  decoration: const InputDecoration(labelText: 'Judul'),
                ),
                TextField(
                  controller: _coverController,
                  decoration: const InputDecoration(labelText: 'URL Cover'),
                ),
                TextField(
                  controller: _penulisController,
                  decoration: const InputDecoration(labelText: 'Penulis'),
                ),
                TextField(
                  controller: _hargaController,
                  decoration: const InputDecoration(labelText: 'Harga'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _jumlahHalamanController,
                  decoration: const InputDecoration(labelText: 'Jumlah Halaman'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _tahunPenggunaanController,
                  decoration: const InputDecoration(labelText: 'Tahun Penggunaan'),
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField<String>(
                  value: _selectedKategori,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedKategori = newValue!;
                    });
                  },
                  items: _kategoriOptions.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: const InputDecoration(labelText: 'Kategori'),
                ),
                TextField(
                  controller: _jumlahBukuController,
                  decoration: const InputDecoration(labelText: 'Jumlah Buku'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _addBook,
                  child: const Text('Tambah Buku'),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
