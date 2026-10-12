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
