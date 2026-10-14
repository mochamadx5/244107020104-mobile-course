import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthRepository {
  Future<String> login(String email, String password) async {
    // Simulasi delay jaringan
    await Future.delayed(const Duration(milliseconds: 500));
    if (email.isNotEmpty && password.isNotEmpty) {
      return 'dummy_jwt_token_${DateTime.now().millisecondsSinceEpoch}';
    }
    throw Exception('Email dan password tidak boleh kosong');
  }
}
