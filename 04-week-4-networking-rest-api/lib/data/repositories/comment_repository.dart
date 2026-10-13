import 'package:dio/dio.dart';
import '../models/comment.dart';

// Class repository untuk memisahkan logika pemanggilan HTTP dari lapisan UI dan State
class CommentRepository {
  // Menerima instance Dio dari luar (dependency injection) agar memakai konfigurasi terpusat
  CommentRepository(this._dio);

  // Menyimpan instance Dio (yang sudah memiliki baseUrl & timeout 10 detik dari api_client.dart)
  final Dio _dio;

  // Method asinkron untuk mengambil daftar komentar berdasarkan postId
  Future<List<Comment>> fetchComments(int postId) async {
    // Melakukan HTTP GET ke '/comments' dengan query parameter '?postId={postId}'
    final response = await _dio.get<List<dynamic>>(
      '/comments',
      queryParameters: {'postId': postId},
    );

    // Jika response.data bernilai null, gunakan list kosong [] sebagai fallback aman
    final data = response.data ?? [];

    // Memfilter elemen yang benar-benar bertipe Map<String, dynamic>,
    // lalu mengubah tiap Map menjadi objek Comment lewat Comment.fromJson, dan menjadikannya List
    return data
        .whereType<Map<String, dynamic>>()
        .map(Comment.fromJson)
        .toList();
  }
}
