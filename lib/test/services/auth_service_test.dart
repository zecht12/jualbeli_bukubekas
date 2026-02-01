// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jualbeli_buku_bekas/services/auth_service.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockAuthResponse extends Mock implements AuthResponse {}
class MockUser extends Mock implements User {}

void main() {
  late AuthService authService;
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();
    when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
    authService = AuthService(client: mockSupabaseClient);
  });

  group('AuthService Unit Tests', () {
    const email = 'gilangprimaertansyah76@gmail.com';
    const password = 'mada66ra';
    const fullName = 'Gilang';

    test('signIn harus berhasil dengan email dan password yang valid', () async {
      final mockResponse = MockAuthResponse();
      final mockUser = MockUser();
      
      when(() => mockResponse.user).thenReturn(mockUser);
      when(() => mockGoTrueClient.signInWithPassword(
            email: email,
            password: password,
          )).thenAnswer((_) async => mockResponse);

      final result = await authService.signIn(email: email, password: password);
      
      expect(result.user, isNotNull);
      verify(() => mockGoTrueClient.signInWithPassword(
            email: email,
            password: password,
          )).called(1);
    });

    test('signUp harus memanggil fungsi signUp dengan metadata full_name', () async {
      final mockResponse = MockAuthResponse();
      
      when(() => mockGoTrueClient.signUp(
            email: email,
            password: password,
            data: {'full_name': fullName},
          )).thenAnswer((_) async => mockResponse);

      await authService.signUp(
        email: email, 
        password: password, 
        fullName: fullName
      );
      
      verify(() => mockGoTrueClient.signUp(
            email: email,
            password: password,
            data: {'full_name': fullName},
          )).called(1);
    });

    test('signOut harus memanggil fungsi signOut dari library Supabase', () async {
      when(() => mockGoTrueClient.signOut()).thenAnswer((_) async => {});
      
      await authService.signOut();
      
      verify(() => mockGoTrueClient.signOut()).called(1);
    });

    test('isAuthenticated mengembalikan true jika sesi aktif', () {
      final mockUser = MockUser();
      when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);
      
      expect(authService.isAuthenticated, isTrue);
    });
  });
}