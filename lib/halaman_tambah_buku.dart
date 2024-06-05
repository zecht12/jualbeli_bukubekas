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

  String _selectedKategori = 'Fiksi'; // Default value for kategori
  final List<String> _kategoriOptions = ['Fiksi', 'Non-Fiksi', 'Komik', 'Sejarah', 'Biografi']; // Example categories

  Future<void> _addBook() async {
    CollectionReference books = FirebaseFirestore.instance.collection('books');

    await books.add({
      'judul': _judulController.text,
      'cover': _coverController.text,
      'penulis': _penulisController.text,
      'harga': int.parse(_hargaController.text),
      'jumlah_halaman': int.parse(_jumlahHalamanController.text),
      'tahun_penggunaan': int.parse(_tahunPenggunaanController.text),
      'jumlah_buku': int.parse(_jumlahBukuController.text),
      'kategori': _selectedKategori,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Buku')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Judul', style: TextStyle(fontSize: 20)),
              TextField(controller: _judulController),
              const SizedBox(height: 10),
              const Text('Url Cover', style: TextStyle(fontSize: 20)),
              TextField(controller: _coverController),
              const SizedBox(height: 10),
              const Text('Penulis', style: TextStyle(fontSize: 20)),
              TextField(controller: _penulisController),
              const SizedBox(height: 10),
              const Text('Harga', style: TextStyle(fontSize: 20)),
              TextField(controller: _hargaController),
              const SizedBox(height: 10),
              const Text('Jumlah Halaman', style: TextStyle(fontSize: 20)),
              TextField(controller: _jumlahHalamanController),
              const SizedBox(height: 10),
              const Text('Tahun Penggunaan', style: TextStyle(fontSize: 20)),
              TextField(controller: _tahunPenggunaanController),
              const SizedBox(height: 10),
              const Text('Jumlah Buku', style: TextStyle(fontSize: 20)),
              TextField(controller: _jumlahBukuController),
              const SizedBox(height: 10),
              const Text('Kategori', style: TextStyle(fontSize: 20)),
              DropdownButton<String>(
                value: _selectedKategori,
                onChanged: (newValue) {
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
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await _addBook();
                    Navigator.pop(context);
                  },
                  child: const Text('Tambah Buku', style: TextStyle(fontSize: 20)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
