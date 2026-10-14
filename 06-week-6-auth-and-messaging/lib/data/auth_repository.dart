import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthTokens {
  final String accessToken;
  final String refreshToken;

  AuthTokens({required this.accessToken, required this.refreshToken});
}

class AuthRepository {
  Future<String> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (email.isNotEmpty && password.isNotEmpty) {
      return 'dummy_jwt_access_token_${DateTime.now().millisecondsSinceEpoch}';
    }
    throw Exception('Email dan password tidak boleh kosong');
  }

  // Dipanggil oleh api_client.dart saat interceptor mendeteksi 401 Unauthorized
  Future<String> refresh(String refreshToken) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (refreshToken.isNotEmpty) {
      return 'new_refreshed_access_token_${DateTime.now().millisecondsSinceEpoch}';
    }
    throw Exception('Refresh token tidak valid');
  }
}
