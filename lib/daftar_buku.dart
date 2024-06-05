import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'halaman_checkout.dart';

class DaftarBuku extends StatelessWidget {
  const DaftarBuku({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Buku')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('books').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var book = snapshot.data!.docs[index];
              bool isReady = book['status'] == 'ready';
              return GestureDetector(
                onTap: () {
                  if (isReady) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HalamanCheckout(
                          bookId: book.id,
                          bookTitle: book['judul'],
                          bookPrice: book['harga'].toDouble(),
                        ),
                      ),
                    );
                  }
                },
                child: Card(
                  child: Column(
                    children: [
                      Image.network(book['cover']),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(book['judul'], style: const TextStyle(fontSize: 20)),
                            Text('Penulis: ${book['penulis']}', style: const TextStyle(fontSize: 16)),
                            Text('Kategori: ${book['kategori']}', style: const TextStyle(fontSize: 16)), // Added this line
                            Text('Harga: Rp ${book['harga']}', style: const TextStyle(fontSize: 16)),
                            Text('Jumlah Buku: ${book['jumlah_buku']}', style: const TextStyle(fontSize: 16)),
                            Text('Jumlah Halaman: ${book['jumlah_halaman']}', style: const TextStyle(fontSize: 16)),
                            Text('Tahun Penggunaan: ${book['tahun_penggunaan']}', style: const TextStyle(fontSize: 16)),
                            Text(
                              book['status'] == 'terjual' ? 'Terjual' : 'Ready',
                              style: TextStyle(
                                fontSize: 16,
                                color: book['status'] == 'terjual' ? Colors.red : (isReady ? Colors.green : Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
