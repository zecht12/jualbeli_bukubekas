// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'halaman_registrasi.dart';

class HalamanLogin extends StatelessWidget {
  const HalamanLogin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HalamanRegistrasi()),
            );
          },
          child: const Text(
            'Login',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
