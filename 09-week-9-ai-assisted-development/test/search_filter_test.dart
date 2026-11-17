import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/features/notes/domain/entities/note.dart';
import 'package:week5_offline_notes/features/notes/domain/usecases/filter_notes.dart';
import 'package:week5_offline_notes/features/notes/presentation/pages/notes_page.dart';
import 'package:week5_offline_notes/features/notes/presentation/providers/notes_providers.dart';

void main() {
  final sampleNotes = [
    Note(id: 1, title: 'Tugas PCVK', body: 'Deteksi tepi', updatedAt: DateTime(2026, 10, 19)),
    Note(id: 2, title: 'Belanja Mingguan', body: 'Buah dan sayur', updatedAt: DateTime(2026, 10, 19)),
  ];

  group('Unit Test: filterNotesByTitle (Domain Layer)', () {
    test('1. Query cocok mengembalikan catatan yang sesuai', () {
      final result = filterNotesByTitle(sampleNotes, 'pcvk');
      expect(result.length, 1);
      expect(result.first.title, 'Tugas PCVK');
    });

    test('2. Query tidak cocok mengembalikan list kosong', () {
      final result = filterNotesByTitle(sampleNotes, 'matematika');
      expect(result, isEmpty);
    });

    test('3. Query spasi kosong mengembalikan semua catatan', () {
      final result = filterNotesByTitle(sampleNotes, '   ');
      expect(result.length, 2);
    });
  });

  testWidgets('4. Widget Test: Tampilkan empty state saat pencarian tidak cocok', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notesProvider.overrideWith((ref) async => sampleNotes),
          dirtyCountProvider.overrideWith((ref) async => 0),
        ],
        child: const MaterialApp(home: NotesPage()),
      ),
    );

    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('search_field')), 'matematika');
    await tester.pumpAndSettle();

    expect(find.text('Catatan tidak ditemukan'), findsOneWidget);
  });
}
