import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jualbeli_buku_bekas/main.dart';
import 'package:jualbeli_buku_bekas/core/constants/api_constants.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    
    await Supabase.initialize(
      url: ApiConstants.supabaseUrl,
      anonKey: ApiConstants.supabaseAnonKey,
    );
  });

  testWidgets('Aplikasi harus dapat dimuat tanpa error Supabase', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.byType(MyApp), findsOneWidget);
  });
}