// ignore_for_file: depend_on_referenced_packages
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jualbeli_buku_bekas/services/book_service.dart';
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder<PostgrestList> {}
class MockPostgrestTransformBuilder extends Mock implements PostgrestTransformBuilder<PostgrestList> {}

void main() {
  late BookService bookService;
  late MockSupabaseClient mockSupabase;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;
  late MockPostgrestTransformBuilder mockTransformBuilder;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();
    mockTransformBuilder = MockPostgrestTransformBuilder();

    bookService = BookService(client: mockSupabase);

    registerFallbackValue(const <String, dynamic>{});
  });

  group('BookService Unit Tests', () {
    test('getAllBooks harus mengembalikan list buku', () async {
      final PostgrestList mockData = [
        {'id': '1', 'title': 'Buku Test', 'price': 50000},
      ];

      when(() => mockSupabase.from('books')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.order(any(), ascending: any())).thenReturn(mockTransformBuilder);
      
      when(() => mockTransformBuilder.then(any())).thenAnswer((invocation) {
        final callback = invocation.positionalArguments[0] as Function(PostgrestList);
        return callback(mockData);
      });

      final result = await bookService.getAllBooks();

      expect(result, isA<List<Map<String, dynamic>>>());
      expect(result.first['title'], 'Buku Test');
    });

    test('addBook harus memanggil insert dengan data yang benar', () async {
      when(() => mockSupabase.from('books')).thenReturn(mockQueryBuilder);
      final mockInsertBuilder = MockPostgrestFilterBuilder();
      when(() => mockQueryBuilder.insert(any())).thenReturn(mockInsertBuilder);
      when(() => mockInsertBuilder.then(any())).thenAnswer((i) => i.positionalArguments[0]([]));

      await bookService.addBook(
        title: 'Judul Baru',
        description: 'Deskripsi',
        price: 20000,
        imageUrl: 'url',
        userId: 'user123',
        category: 'Hobi',
        condition: 'Bagus',
        stock: 5,
      );

      verify(() => mockSupabase.from('books')).called(1);
    });

    test('deleteBook harus memanggil delete dan eq filter', () async {
      when(() => mockSupabase.from('books')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.delete()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq(any(), any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.then(any())).thenAnswer((i) => i.positionalArguments[0]([]));

      await bookService.deleteBook('123');

      verify(() => mockQueryBuilder.delete()).called(1);
      verify(() => mockFilterBuilder.eq('id', '123')).called(1);
    });

    test('getMyBooks harus memfilter berdasarkan user_id', () async {
      when(() => mockSupabase.from('books')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq(any(), any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.order(any(), ascending: any())).thenReturn(mockTransformBuilder);
      when(() => mockTransformBuilder.then(any())).thenAnswer((i) => i.positionalArguments[0]([]));

      await bookService.getMyBooks('user123');

      verify(() => mockFilterBuilder.eq('user_id', 'user123')).called(1);
    });
  });
}