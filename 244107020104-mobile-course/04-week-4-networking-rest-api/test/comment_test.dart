import 'package:flutter_test/flutter_test.dart';

// ignore: avoid_relative_lib_imports
import '../lib/data/models/comment.dart';

void main() {
  group('Pengujian Comment.fromJson', () {
    // 1. Unit test wajib: menguji fromJson dengan field yang hilang
    test('harus memberikan nilai default aman ketika ada field yang hilang', () {
      final jsonFieldHilang = <String, dynamic>{
        'id': 10,
        'name': 'Komentar Uji',
        // postId, email, dan body sengaja dihilangkan
      };

      final comment = Comment.fromJson(jsonFieldHilang);

      expect(comment.postId, 0);
      expect(comment.id, 10);
      expect(comment.name, 'Komentar Uji');
      expect(comment.email, '');
      expect(comment.body, '');
    });

    // 2. Edge case tambahan: field bernilai null eksplisit & angka double
    test('Edge case: tetap aman saat field bernilai null eksplisit atau bertipe double', () {
      final jsonEdgeCase = <String, dynamic>{
        'postId': 2.0,
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
