import 'package:flutter/material.dart';
import 'package:jualbeli_buku_bekas/features/auth/presentation/pages/login_page.dart';
import 'package:jualbeli_buku_bekas/main_navigation.dart';
import 'package:jualbeli_buku_bekas/services/supabase_service.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
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
      home: SupabaseService.client.auth.currentUser != null
          ? const MainNavigation()
          : const LoginPage(),
    );
  }
}