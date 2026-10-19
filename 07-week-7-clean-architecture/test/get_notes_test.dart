import 'package:flutter_test/flutter_test.dart';

// Sesuaikan path import ini jika Anda menggunakan package: atau path absolut
import '../lib/core/failures.dart';
import '../lib/features/notes/domain/entities/note.dart';
import '../lib/features/notes/domain/repositories/note_repository.dart';
import '../lib/features/notes/domain/usecases/get_notes.dart';

// 1. Membuat Repository Palsu (Murni Dart)
class FakeNoteRepository implements NoteRepository {
  FakeNoteRepository({this.items = const [], this.fail = false});
  final List<Note> items;
  final bool fail;

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    if (fail) {
      return (
        notes: const <Note>[],
        failure: const LocalFailure('db locked (simulasi)'),
      );
    }
    return (notes: items, failure: null);
  }

  // Wajib melakukan override pada metode kontrak lainnya 
  // (karena GetNotes tidak memanggil fungsi ini, kita bisa lemparkan UnimplementedError)
  @override
  Future<({Note? note, Failure? failure})> addNote({required String title, String body = ''}) {
    throw UnimplementedError();
  }

  @override
  Future<Failure?> deleteNote(int id) {
    throw UnimplementedError();
  }

  @override
  Future<({int count, Failure? failure})> countDirty() {
    throw UnimplementedError();
  }

  @override
  Future<Failure?> markAllSynced() {
    throw UnimplementedError();
  }
}

// 2. Blok Pengujian (Unit Test)
void main() {
  test('GetNotes meneruskan daftar dari repository jika sukses', () async {
    // Arrange: Siapkan fake repository berisi 1 data tiruan
    final repo = FakeNoteRepository(
      items: [
        Note(title: 'Tugas A', updatedAt: DateTime(2026, 9, 27)),
      ],
    );

    // Act: Panggil Use Case
    final result = await GetNotes(repo).call();

    // Assert: Verifikasi bahwa failure null dan data tertangkap
    expect(result.failure, isNull);
    expect(result.notes.length, 1);
    expect(result.notes.first.title, 'Tugas A');
  });

  test('GetNotes meneruskan failure tanpa melempar exception jika gagal', () async {
    // Arrange: Siapkan fake repository yang diatur untuk selalu gagal
    final repo = FakeNoteRepository(fail: true);

    // Act: Panggil Use Case
    final result = await GetNotes(repo).call();

    // Assert: Verifikasi bahwa tipe error sesuai dan daftar kosong
    expect(result.failure, isA<LocalFailure>());
    expect(result.notes, isEmpty);
  });
}
