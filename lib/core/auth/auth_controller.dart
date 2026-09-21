import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../api/api_error.dart';
import 'me.dart';
import 'token_store.dart';

enum AuthStatus { loading, anon, authed }

class AuthState {
  const AuthState(this.status, this.me);
  final AuthStatus status;
  final Me? me;
}

final tokenStoreProvider = Provider<TokenStore>((_) => TokenStore());
final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient(ref.watch(tokenStoreProvider));
  client.onSessionLost = () => ref.read(authControllerProvider.notifier).sessionLost();
  return client;
});
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) => AuthController(ref));

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._ref) : super(const AuthState(AuthStatus.loading, null));
  final Ref _ref;
  ApiClient get _api => _ref.read(apiClientProvider);
  TokenStore get _tokens => _ref.read(tokenStoreProvider);

  /// App start: refresh from the stored token, then load /auth/me.
  Future<void> bootstrap() async {
    if (_tokens.accessToken == null && !await _api.refresh()) {
      state = const AuthState(AuthStatus.anon, null);
      return;
    }
    await _loadMe();
  }

  Future<void> _loadMe() async {
    try {
      final me = Me.fromJson(await _api.get<Map<String, dynamic>>('/auth/me'));
      state = AuthState(AuthStatus.authed, me);
    } on ApiError catch (e) {
      if (e.status == 401 || e.status == 403) {
        await _tokens.clear();
        state = const AuthState(AuthStatus.anon, null);
      } else {
        rethrow;
      }
    }
  }

  Future<Me> login(String phone, String password) async {
    final r = await _api.post<Map<String, dynamic>>('/auth/login', data: {'phone': phone, 'password': password});
    _tokens.accessToken = r['access_token'] as String;
    await _tokens.writeRefresh(r['refresh_token'] as String);
    await _loadMe();
    return state.me!;
  }

  Future<void> logout() async {
    final rt = await _tokens.readRefresh();
    try {
      await _api.post('/auth/logout', data: {'refresh_token': rt});
    } catch (_) {}
    await _tokens.clear();
    state = const AuthState(AuthStatus.anon, null);
  }

  Future<void> changePassword({String? current, required String next}) async {
    await _api.post('/auth/change-password', data: {if (current != null) 'current_password': current, 'new_password': next});
    await logout();
  }

  Future<void> refreshMe() => _loadMe();
  void sessionLost() => state = const AuthState(AuthStatus.anon, null);
}
