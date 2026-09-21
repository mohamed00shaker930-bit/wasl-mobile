import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Refresh token lives in the platform keystore; the access token only in memory.
class TokenStore {
  TokenStore([FlutterSecureStorage? storage]) : _storage = storage ?? const FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));
  final FlutterSecureStorage _storage;
  static const _refreshKey = 'wasl_refresh_token';

  String? accessToken;

  Future<String?> readRefresh() => _storage.read(key: _refreshKey);
  Future<void> writeRefresh(String? token) => token == null ? _storage.delete(key: _refreshKey) : _storage.write(key: _refreshKey, value: token);
  Future<void> clear() async {
    accessToken = null;
    await _storage.delete(key: _refreshKey);
  }
}
