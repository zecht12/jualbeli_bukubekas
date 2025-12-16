// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jualbeli_buku_bekas/services/auth_service.dart';
import 'package:jualbeli_buku_bekas/shared/widgets/custom_snackbar.dart';

class AuthController {
  final AuthService _authService = AuthService();
  Future<void> login(BuildContext context, {
    required String email,
    required String password,
  }) async {
    try {
      await _authService.signIn(email: email, password: password);

      if (context.mounted) {
        CustomSnackbar.showSuccess(context, 'Berhasil masuk!');
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (context.mounted) {
        String message = e.toString().replaceAll('Exception: ', '');
        if (message.contains('Invalid login credentials')) {
          message = 'Email atau password salah.';
        }
        CustomSnackbar.showError(context, message);
      }
    }
  }

  Future<void> register(BuildContext context, {
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );

      if (context.mounted) {
        CustomSnackbar.showSuccess(context, 'Akun berhasil dibuat! Silakan login.');
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        String message = e.toString().replaceAll('Exception: ', '');
        if (message.contains('User already registered')) {
          message = 'Email sudah terdaftar.';
        }
        CustomSnackbar.showError(context, message);
      }
    }
  }

  Future<void> logout(BuildContext context) async {
    await _authService.signOut();
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }
}