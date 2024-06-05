import 'package:flutter/material.dart';
import 'halaman_edit_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HalamanProfile extends StatelessWidget {
  const HalamanProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No user data found.'));
          }

          Map<String, dynamic>? userData =
              snapshot.data!.data() as Map<String, dynamic>?;
          String name = userData?['name'] ?? 'No name';
          String email = userData?['email'] ?? 'No email';
          String nim = userData?['nim'] ?? 'No NIM';
          String profileImageUrl = userData?['profileImage'] ?? '';
          String alamat = userData?['alamat'] ?? 'No address';
          String role = userData?['role'] ?? 'No role';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                    profileImageUrl.isNotEmpty
                        ? profileImageUrl
                        : 'https://via.placeholder.com/150',
                  ),
                ),
                const SizedBox(height: 16),
                Text(name, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 16),
                InfoTile(icon: Icons.email, text: email),
                InfoTile(icon: Icons.account_box, text: nim),
                InfoTile(icon: Icons.home, text: alamat),
                InfoTile(icon: Icons.verified_user, text: role),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HalamanEditProfile(userData: userData!)),
                    );
                  },
                  child: const Text('Edit profile'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class InfoTile extends StatelessWidget {
  final IconData icon;
  final String text;

  const InfoTile({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
    );
  }
}
