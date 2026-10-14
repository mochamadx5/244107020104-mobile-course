import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final tokenStoreProvider = Provider<TokenStore>((ref) {
  return TokenStore();
});

class TokenStore {
  final _storage = const FlutterSecureStorage();
  static const _keyAccess = 'access_token';
  static const _keyRefresh = 'refresh_token';

  // Dipanggil oleh api_client.dart
  Future<String?> readAccess() async {
    return await _storage.read(key: _keyAccess);
  }

  Future<String?> readRefresh() async {
    return await _storage.read(key: _keyRefresh);
  }

  Future<void> save({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _storage.write(key: _keyAccess, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _keyRefresh, value: refreshToken);
    }
  }

  Future<void> clear() async {
    await _storage.delete(key: _keyAccess);
    await _storage.delete(key: _keyRefresh);
  }

  // Kompatibilitas alias untuk provider
  Future<String?> getToken() => readAccess();
  Future<void> saveToken(String token) => save(accessToken: token);
  Future<void> deleteToken() => clear();
}
