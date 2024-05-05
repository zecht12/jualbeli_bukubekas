// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'halaman_checkout.dart';

class DaftarBuku extends StatelessWidget {
  const DaftarBuku({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HalamanCheckout(bookId: '', bookTitle: '', bookPrice: 0.0)),
            );
          },
          child: ListTile(
            title: Text(
              'Judul Buku $index',
              style: const TextStyle(fontSize: 18),
            ),
            subtitle: Text(
              'Penulis $index',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        );
      },
    );
  }
}
