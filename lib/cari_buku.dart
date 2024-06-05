// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'halaman_checkout.dart';

class CariBuku extends StatefulWidget {
  const CariBuku({super.key});

  @override
  _CariBukuState createState() => _CariBukuState();
}

class _CariBukuState extends State<CariBuku> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Cari judul, penulis, atau kategori',
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _searchTerm = _searchController.text.toLowerCase().trim();
                });
              },
            ),
          ),
          onSubmitted: (value) {
            setState(() {
              _searchTerm = value.toLowerCase().trim();
            });
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('books').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var books = snapshot.data!.docs;
          if (_searchTerm.isNotEmpty) {
            books = books.where((doc) {
              var data = doc.data() as Map<String, dynamic>;
              var penulis = data['penulis'].toString().toLowerCase();
              var kategori = data['kategori'].toString().toLowerCase();
              var judul = data['judul'].toString().toLowerCase();

              return penulis.contains(_searchTerm) ||
                  kategori.contains(_searchTerm) ||
                  judul.contains(_searchTerm);
            }).toList();
          }

          if (books.isEmpty) {
            return const Center(child: Text('No books found.'));
          }

          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              var book = books[index];
              return Padding(
                padding: const EdgeInsets.all(5.0),
                child: ListTile(
                  title: Text(book['judul']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Penulis: ${book['penulis']}'),
                      Text('Kategori: ${book['kategori']}'), // Added this line
                    ],
                  ),
                  trailing: Text('Harga: Rp ${book['harga']}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HalamanCheckout(
                          bookId: book.id,
                          bookTitle: book['judul'],
                          bookPrice: (book['harga'] is int)
                              ? (book['harga'] as int).toDouble()
                              : book['harga'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
