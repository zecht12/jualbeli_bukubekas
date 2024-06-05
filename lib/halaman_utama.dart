// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'daftar_buku.dart';
import 'halaman_tambah_buku.dart';
import 'halaman_login.dart';
import 'cari_buku.dart';

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
            onSelected: (value) async {
              if (value == 'add_book') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HalamanTambahBuku()),
                );
              } else if (value == 'sign_out') {
                await FirebaseAuth.instance.signOut();
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
            ListTile(
              title: const Text(
                'Cari',
                style: TextStyle(fontSize: 30),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CariBuku()), // Navigate to CariBuku
                );
              },
            ),
          ],
        ),
      ),
      body: const DaftarBuku(),
    );
  }
}
