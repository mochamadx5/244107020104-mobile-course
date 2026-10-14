import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final tokenStoreProvider = Provider<TokenStore>((ref) {
  return TokenStore();
});

class TokenStore {
  final _storage = const FlutterSecureStorage();
  static const _keyAccess = 'access_token';
  static const _keyRefresh = 'refresh_token';

  Future<String?> readAccess() async {
    return await _storage.read(key: _keyAccess);
  }

  Future<String?> readRefresh() async {
    return await _storage.read(key: _keyRefresh);
  }

  Future<void> save({
    required String access,
    String? refresh,
  }) async {
    await _storage.write(key: _keyAccess, value: access);
    if (refresh != null) {
      await _storage.write(key: _keyRefresh, value: refresh);
    }
  }

  // Method clear untuk menghapus kedua token saat logout/401 expired
  Future<void> clear() async {
    await _storage.delete(key: _keyAccess);
    await _storage.delete(key: _keyRefresh);
  }

  // Alias kompatibilitas
  Future<String?> getToken() => readAccess();
  Future<void> saveToken(String token) => save(access: token);
  Future<void> deleteToken() => clear();
}
