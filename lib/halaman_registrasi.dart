import 'package:flutter/material.dart';
import 'halaman_login.dart';
import 'halaman_utama.dart';

class HalamanRegistrasi extends StatelessWidget {
  const HalamanRegistrasi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrasi'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Nama',
                ),
              ),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'NIM (optional)',
                ),
              ),
              const SizedBox(height: 10),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              const SizedBox(height: 10),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Implement registration logic
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HalamanUtama()),
                  );
                },
                child: const Text(
                  'Registrasi',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HalamanLogin()),
                  );
                },
                child: const Text(
                  'Sudah punya akun? Login',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
