import 'package:flutter/material.dart';
import 'halaman_login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://lrltciikazzktjvgelnq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxybHRjaWlrYXp6a3RqdmdlbG5xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTU2NzM4MjksImV4cCI6MjAzMTI0OTgyOX0.9lwrCE1wCNOe-pcJwzdk0LjYW-Rk5qlAvNi0XfRPQl8',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Toko Buku',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookstore'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HalamanLogin()),
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
