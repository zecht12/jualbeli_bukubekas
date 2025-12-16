import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jualbeli_buku_bekas/features/auth/presentation/pages/login_page.dart';
import 'package:jualbeli_buku_bekas/features/main_navigation.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://kitluqfpabwezzymjqpb.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtpdGx1cWZwYWJ3ZXp6eW1qcXBiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU4ODM4NDMsImV4cCI6MjA4MTQ1OTg0M30.yx3Q9keYd5La57pGn0_sGGUUHkGHARK3QZQnnZZlrG4',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jual Beli Buku Bekas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
      home: Supabase.instance.client.auth.currentUser != null
          ? const MainNavigation()
          : const LoginPage(),
    );
  }
}