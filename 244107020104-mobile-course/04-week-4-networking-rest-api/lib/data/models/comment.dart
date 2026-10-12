// Mendefinisikan class Comment yang bersifat immutable (tidak bisa diubah setelah dibuat)
class Comment {
  // Constructor const dengan named parameter wajib (required) untuk semua field
  const Comment({
    required this.postId,
    required this.id,
    required this.name,
    required this.email,
    required this.body,
  });

  // Deklarasi properti final sesuai struktur JSON dari endpoint /comments
  final int postId;
  final int id;
  final String name;
  final String email;
  final String body;

  // Factory constructor untuk mengubah Map JSON menjadi objek Comment secara aman-null (null-safe)
  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        // Mengambil 'postId' sebagai num? (bisa int/double/null), diubah ke int, jika null diisi 0
        postId: (json['postId'] as num?)?.toInt() ?? 0,
        // Mengambil 'id' sebagai num?, diubah ke int, jika null atau hilang diisi 0
        id: (json['id'] as num?)?.toInt() ?? 0,
        // Mengambil 'name' sebagai String?, jika null atau hilang diisi string kosong ''
        name: (json['name'] as String?) ?? '',
        // Mengambil 'email' sebagai String?, jika null atau hilang diisi string kosong ''
        email: (json['email'] as String?) ?? '',
        // Mengambil 'body' sebagai String?, jika null atau hilang diisi string kosong ''
        body: (json['body'] as String?) ?? '',
      );
}
