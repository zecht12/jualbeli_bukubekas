// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'daftar_buku.dart';
import 'halaman_tambah_buku.dart';
import 'halaman_login.dart';
import 'cari_buku.dart';
import 'halaman_profile.dart';

class HalamanUtama extends StatelessWidget {
  const HalamanUtama({super.key});

  Future<String?> _getUserRole() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();

    if (userDoc.exists) {
      return userDoc['role'];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CariBuku()),
            );
          },
        ),
        title: const Text('Toko Buku'),
        centerTitle: true,
        actions: [
          FutureBuilder<String?>(
            future: _getUserRole(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              String? role = snapshot.data;
              return Row(
                children: [
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser?.uid)
                        .get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return const Icon(Icons.account_circle);
                      }

                      Map<String, dynamic>? userData =
                          snapshot.data!.data() as Map<String, dynamic>?;
                      String profileImageUrl = userData?['profileImage'] ?? '';

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const HalamanProfile()),
                          );
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(
                            profileImageUrl.isNotEmpty
                                ? profileImageUrl
                                : 'https://via.placeholder.com/150',
                          ),
                        ),
                      );
                    },
                  ),
                  PopupMenuButton(
                    itemBuilder: (BuildContext context) {
                      List<PopupMenuItem<String>> menuItems = [
                        const PopupMenuItem(
                          value: 'sign_out',
                          child: Text('Keluar'),
                        ),
                      ];

                      if (role == 'admin') {
                        menuItems.insert(
                          0,
                          const PopupMenuItem(
                            value: 'add_book',
                            child: Text('Tambah Buku'),
                          ),
                        );
                      }

                      return menuItems;
                    },
                    onSelected: (value) async {
                      if (value == 'add_book') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HalamanTambahBuku()),
                        );
                      } else if (value == 'sign_out') {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HalamanLogin()),
                          (route) => false,
                        );
                      }
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: const DaftarBuku(),
    );
  }
}