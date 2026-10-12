import 'package:flutter_test/flutter_test.dart';
// Menggunakan relative import agar tidak bergantung pada nama package di pubspec.yaml
import '../lib/data/models/comment.dart';

void main() {
  group('Pengujian Comment.fromJson', () {
    // Test 1: Skenario wajib dari prompt (field hilang / missing fields)
    test('harus memberikan nilai fallback aman ketika ada field yang hilang', () {
      // JSON hanya berisi id dan name; postId, email, dan body sengaja dihilangkan
      final jsonFieldHilang = <String, dynamic>{
        'id': 10,
        'name': 'Komentar Uji',
      };

      // Mem-parsing JSON yang tidak lengkap
      final comment = Comment.fromJson(jsonFieldHilang);

      // Memastikan field yang hilang otomatis bernilai default (0 atau '') tanpa crash
      expect(comment.postId, 0);
      expect(comment.id, 10);
      expect(comment.name, 'Komentar Uji');
      expect(comment.email, '');
      expect(comment.body, '');
    });

    // Test 2: Edge case tambahan mandiri (seluruh field bernilai null & tipe angka double)
    test('Edge case: tetap aman saat field bernilai null eksplisit atau bertipe double', () {
      final jsonEdgeCase = <String, dynamic>{
        'postId': 2.0, // bertipe double, harus tetap berhasil diubah ke int 2
        'id': null,
        'name': null,
        'email': null,
        'body': null,
      };

      final comment = Comment.fromJson(jsonEdgeCase);

      expect(comment.postId, 2);
      expect(comment.id, 0);
      expect(comment.name, '');
      expect(comment.email, '');
      expect(comment.body, '');
    });
  });
}
