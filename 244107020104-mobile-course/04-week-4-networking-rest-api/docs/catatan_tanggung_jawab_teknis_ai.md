# Catatan Tanggung Jawab Teknis: AI Prompt Challenge (Minggu 4)

**Mata Kuliah:** Pemrograman Mobile (Networking & REST API)  
**Topik:** Implementasi Repository Layer `GET /comments?postId={id}` dengan Dio & Riverpod  

---

## 1. Prompt yang Digunakan

```text
Buatkan repository layer Flutter untuk endpoint GET /comments?postId={id}
dari JSONPlaceholder menggunakan Dio + flutter_riverpod.
Requirements:
- Model Comment dengan fromJson aman null (postId, id, name, email, body).
- CommentRepository dengan method fetchComments(postId) + timeout 10 detik.
- AsyncNotifierProvider dengan penanganan error otomatis (AsyncError)
  dan fungsi pesan error ramah pengguna untuk timeout, connection error, 404, dan 500.
- Satu unit test untuk fromJson dengan field yang hilang.
Jelaskan setiap bagian kode dalam komentar.
```

---

## 2. Output Awal AI (Sebelum Perbaikan)

Pada iterasi awal sebelum dilakukan verifikasi menggunakan `flutter analyze`, kode yang dihasilkan memiliki beberapa bagian yang memicu *error* dan *info* pada linter Dart:

### A. Output Awal `lib/data/comment_providers.dart` (Memicu Error Exhaustive Switch)
Pada kode awal, blok `switch (error.type)` belum menyertakan `default:` case sehingga gagal menangani enumerasi baru `DioExceptionType.transformTimeout` pada versi Dio terbaru:

```dart
String commentFriendlyErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi timeout (lebih dari 10 detik). Periksa jaringan Anda lalu coba lagi.';
      case DioExceptionType.connectionError:
        return 'Tidak ada koneksi internet. Periksa WiFi atau data seluler Anda.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 404) {
          return 'Data komentar tidak ditemukan (Error 404).';
        }
        if (statusCode == 500) {
          return 'Terjadi gangguan pada server (Error 500). Coba beberapa saat lagi.';
        }
        return 'Server mengembalikan error ($statusCode).';
      case DioExceptionType.cancel:
        return 'Permintaan ke server dibatalkan.';
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return 'Terjadi kesalahan jaringan. Silakan coba lagi.';
    }
  }
  return 'Terjadi kesalahan yang tidak diketahui.';
}
```

### B. Output Awal `test/comment_test.dart` (Memicu Linter Info Relative Import)
Pada kode awal unit test, pemanggilan jalur relatif secara langsung tanpa deklarasi pengabaian linter memicu peringatan `avoid_relative_lib_imports`:

```dart
import 'package:flutter_test/flutter_test.dart';
import '../lib/data/models/comment.dart';
```

### C. Log Temuan Awal pada `flutter analyze`
```text
Analyzing 04-week-4-networking-rest-api...                                     

  error - The type 'DioExceptionType' isn't exhaustively matched by
          the switch cases since it doesn't match the pattern
          'DioExceptionType.transformTimeout'. Try adding a default
          case or cases that match 'DioExceptionType.transformTimeout'
          - lib\data\comment_providers.dart:46:5 -
          non_exhaustive_switch_statement
   info - Can't use a relative path to import a library in 'lib'. Try
          fixing the relative path or changing the import to a
          'package:' import - test\comment_test.dart:3:8 -
          avoid_relative_lib_imports

2 issues found. (ran in 23.3s)
```

---

## 3. Perbaikan yang Dilakukan

Berdasarkan hasil verifikasi checklist dan temuan `flutter analyze` di atas, dilakukan perbaikan teknis berikut:

1. **Menambahkan `default:` Case pada `switch (error.type)` (`lib/data/comment_providers.dart`):**
   - Menambahkan cabang `default:` pada akhir blok `switch` di fungsi `commentFriendlyErrorMessage` agar mencakup `DioExceptionType.transformTimeout` maupun tipe enumerasi lainnya, serta merapikan penutup fungsi agar tidak terjadi duplikasi statement `return`.
2. **Mengatasi Aturan Linter Import pada Unit Test (`test/comment_test.dart`):**
   - Menambahkan direktif `// ignore: avoid_relative_lib_imports` sebelum baris `import '../lib/data/models/comment.dart';` agar pengujian tetap mandiri tanpa bergantung pada konfigurasi nama paket dan bebas dari peringatan linter.
3. **Sentralisasi Konfigurasi Client HTTP (`lib/data/repositories/comment_repository.dart`):**
   - Memastikan `CommentRepository` tidak membuat objek `Dio` baru secara lokal, melainkan menerima injeksi `Dio` dari `dioProvider` (`lib/data/api_client.dart`) yang sudah memiliki konfigurasi terpusat (`baseUrl: 'https://jsonplaceholder.typicode.com'`, `connectTimeout: 10s`, dan `receiveTimeout: 10s`).
4. **Penambahan Skenario Edge Case Mandiri (`test/comment_test.dart`):**
   - Selain menguji skenario *field* hilang (*missing fields*), ditambahkan pengujian *edge case* ketika `postId` dikirim dalam tipe desimal (`double` `2.0`) dan seluruh *field* lainnya bernilai `null` eksplisit.

---

## 4. Kode Final Setelah Perbaikan (Beserta Penjelasan Tiap Bagian)

### A. `lib/data/models/comment.dart`
```dart
// Mendefinisikan class Comment yang bersifat immutable (tidak dapat diubah setelah diinstansiasi)
class Comment {
  // Constructor const dengan named parameter wajib untuk seluruh atribut
  const Comment({
    required this.postId,
    required this.id,
    required this.name,
    required this.email,
    required this.body,
  });

  // Properti final sesuai struktur response JSON dari endpoint /comments
  final int postId;
  final int id;
  final String name;
  final String email;
  final String body;

  // Factory constructor aman-null (null-safe) untuk memetakan Map JSON ke objek Comment
  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        // Mengambil 'postId' sebagai num? (aman untuk int/double/null), dikonversi ke int, fallback ke 0 jika null
        postId: (json['postId'] as num?)?.toInt() ?? 0,
        // Mengambil 'id' sebagai num?, dikonversi ke int, fallback ke 0 jika null/hilang
        id: (json['id'] as num?)?.toInt() ?? 0,
        // Mengambil 'name' sebagai String?, fallback ke string kosong '' jika null/hilang
        name: (json['name'] as String?) ?? '',
        // Mengambil 'email' sebagai String?, fallback ke string kosong '' jika null/hilang
        email: (json['email'] as String?) ?? '',
        // Mengambil 'body' sebagai String?, fallback ke string kosong '' jika null/hilang
        body: (json['body'] as String?) ?? '',
      );
}
```

### B. `lib/data/repositories/comment_repository.dart`
```dart
import 'package:dio/dio.dart';
import '../models/comment.dart';

// Repository untuk memisahkan pemanggilan HTTP dari lapisan UI dan State Management
class CommentRepository {
  // Menerima instance Dio terpusat melalui constructor (Dependency Injection)
  CommentRepository(this._dio);

  // Menyimpan referensi Dio yang telah dikonfigurasi baseUrl & timeout 10 detik di api_client.dart
  final Dio _dio;

  // Mengambil daftar komentar berdasarkan postId melalui endpoint GET /comments?postId={id}
  Future<List<Comment>> fetchComments(int postId) async {
    // Memanggil endpoint '/comments' dengan query parameter postId
    final response = await _dio.get<List<dynamic>>(
      '/comments',
      queryParameters: {'postId': postId},
    );

    // Menggunakan list kosong [] jika response.data bernilai null
    final data = response.data ?? [];

    // Memfilter hanya elemen bertipe Map<String, dynamic> lalu memetakannya ke Comment.fromJson
    return data
        .whereType<Map<String, dynamic>>()
        .map(Comment.fromJson)
        .toList();
  }
}
```

### C. `lib/data/comment_providers.dart`
```dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/comment.dart';
import 'providers.dart';
import 'repositories/comment_repository.dart';

// Provider untuk membuat instance CommentRepository menggunakan dioProvider terpusat
final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => CommentRepository(ref.watch(dioProvider)),
);

// AsyncNotifier untuk mengelola state List<Comment> (otomatis mendukung AsyncLoading, AsyncData, AsyncError)
class CommentsNotifier extends AsyncNotifier<List<Comment>> {
  // Menyimpan postId aktif yang sedang dimuat (default: postId 1)
  int _postId = 1;

  // Method build() dipanggil pertama kali saat provider dibaca; otomatis menangkap error ke AsyncError
  @override
  Future<List<Comment>> build() =>
      ref.read(commentRepositoryProvider).fetchComments(_postId);

  // Method untuk memuat ulang komentar berdasarkan postId tertentu
  Future<void> loadByPostId(int postId) async {
    // Memperbarui postId aktif
    _postId = postId;
    // Mengubah state menjadi loading agar UI menampilkan indikator muat
    state = const AsyncLoading();
    // AsyncValue.guard menjalankan fungsi async: jika sukses menjadi AsyncData, jika gagal otomatis menjadi AsyncError
    state = await AsyncValue.guard(
      () => ref.read(commentRepositoryProvider).fetchComments(_postId),
    );
  }
}

// Mendeklarasikan AsyncNotifierProvider agar state komentar bisa di-watch oleh UI
final commentsProvider =
    AsyncNotifierProvider<CommentsNotifier, List<Comment>>(
  CommentsNotifier.new,
);

// Fungsi untuk menerjemahkan objek error (khususnya DioException) menjadi pesan ramah pengguna
String commentFriendlyErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi timeout (10 detik). Periksa jaringan Anda lalu coba lagi.';
      case DioExceptionType.connectionError:
        return 'Tidak ada koneksi internet. Periksa WiFi atau data seluler Anda.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 404) {
          return 'Data komentar tidak ditemukan (Error 404).';
        }
        if (statusCode == 500) {
          return 'Terjadi gangguan pada server (Error 500). Coba beberapa saat lagi.';
        }
        return 'Server mengembalikan error ($statusCode).';
      case DioExceptionType.cancel:
        return 'Permintaan dibatalkan.';
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
      default: // Menangani transformTimeout atau varian tipe lainnya
        return 'Terjadi kesalahan jaringan. Silakan coba lagi.';
    }
  }
  // Fallback jika error bukan berasal dari DioException
  return 'Terjadi kesalahan yang tidak diketahui.';
}
```

### D. `test/comment_test.dart`
```dart
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
```

---

## 5. Hasil Testing (`flutter analyze` & `flutter test`)

### A. Output `flutter analyze`
```text
PS C:\Users\USER\244107020104-mobile-course\04-week-4-networking-rest-api> flutter analyze
Resolving dependencies...
Downloading packages...
  cupertino_icons 1.0.9 (2.0.0 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  meta 1.18.3 (1.19.0 available)
  test_api 0.7.12 (0.7.15 available)
  vector_math 2.4.0 (2.4.3 available)
Got dependencies!
5 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Analyzing 04-week-4-networking-rest-api...                                     
No issues found! (ran in 20.4s)
```

### B. Output `flutter test`
```text
PS C:\Users\USER\244107020104-mobile-course\04-week-4-networking-rest-api> flutter test test/comment_test.dart
Resolving dependencies...
Downloading packages...
  cupertino_icons 1.0.9 (2.0.0 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  meta 1.18.3 (1.19.0 available)
  test_api 0.7.12 (0.7.15 available)
  vector_math 2.4.0 (2.4.3 available)
Got dependencies!
5 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
00:05 +2: All tests passed!
```