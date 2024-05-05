// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:jualbeli_buku_bekas/books_search.dart';
import 'package:jualbeli_buku_bekas/halaman_login.dart';
import 'daftar_buku.dart';
import 'halaman_tambah_buku.dart';

class HalamanUtama extends StatelessWidget {
  const HalamanUtama({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Toko Buku'),
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'add_book',
                  child: Text('Tambah Buku'),
                ),
                const PopupMenuItem(
                  value: 'sign_out',
                  child: Text('Keluar'),
                ),
              ];
            },
            onSelected: (value) {
              if (value == 'add_book') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HalamanTambahBuku()),
                );
              } else if (value == 'sign_out') {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HalamanLogin()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Cari',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            ListTile(
              title: const Text(
                'Cari',
                style: TextStyle(fontSize: 18),
              ),
              onTap: () {
                showSearch(context: context, delegate: BookSearchDelegate());
              },
            ),
          ],
        ),
      ),
      body: const DaftarBuku(),
    );
  }
}
