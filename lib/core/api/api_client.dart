import 'dart:async';

import 'package:dio/dio.dart';

import '../auth/token_store.dart';
import 'api_error.dart';
import 'env.dart';

/// Dio client for wasl-api. `X-Client: mobile` makes the server return the refresh token in the body.
/// On 401 a single refresh runs; concurrent requests wait for it and are retried once.
class ApiClient {
  ApiClient(this._tokens, {String? baseUrl})
      : dio = Dio(BaseOptions(
          baseUrl: baseUrl ?? Env.apiBaseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
          headers: {'X-Client': 'mobile', 'Accept': 'application/json'},
        )) {
    dio.interceptors.add(QueuedInterceptorsWrapper(onRequest: _onRequest, onError: _onError));
  }

  final Dio dio;
  final TokenStore _tokens;
  Future<bool>? _refreshing;
  void Function()? onSessionLost;

  void _onRequest(RequestOptions o, RequestInterceptorHandler h) {
    final t = _tokens.accessToken;
    if (t != null && !o.headers.containsKey('Authorization')) o.headers['Authorization'] = 'Bearer $t';
    h.next(o);
  }

  Future<void> _onError(DioException e, ErrorInterceptorHandler h) async {
    final path = e.requestOptions.path;
    final retried = e.requestOptions.extra['retried'] == true;
    if (e.response?.statusCode == 401 && !retried && !path.contains('/auth/login') && !path.contains('/auth/refresh')) {
      if (await refresh()) {
        final opts = e.requestOptions..extra['retried'] = true;
        opts.headers['Authorization'] = 'Bearer ${_tokens.accessToken}';
        try {
          return h.resolve(await dio.fetch(opts));
        } on DioException catch (e2) {
          return h.next(e2);
        }
      }
    }
    h.next(e);
  }

  /// Rotates the refresh token. Returns false (and clears the session) when it is expired or reused.
  Future<bool> refresh() {
    return _refreshing ??= () async {
      try {
        final rt = await _tokens.readRefresh();
        if (rt == null) return false;
        final r = await Dio(BaseOptions(baseUrl: dio.options.baseUrl, headers: {'X-Client': 'mobile'})).post('/auth/refresh', data: {'refresh_token': rt});
        final data = r.data as Map<String, dynamic>;
        _tokens.accessToken = data['access_token'] as String;
        await _tokens.writeRefresh(data['refresh_token'] as String);
        return true;
      } on DioException {
        await _tokens.clear();
        onSessionLost?.call();
        return false;
      } finally {
        _refreshing = null;
      }
    }();
  }

  Future<T> get<T>(String path, {Map<String, dynamic>? query}) => _run(() => dio.get<T>(path, queryParameters: query));
  Future<T> post<T>(String path, {Object? data, Map<String, dynamic>? query}) => _run(() => dio.post<T>(path, data: data ?? {}, queryParameters: query));
  Future<T> put<T>(String path, {Object? data}) => _run(() => dio.put<T>(path, data: data ?? {}));
  Future<T> patch<T>(String path, {Object? data}) => _run(() => dio.patch<T>(path, data: data ?? {}));
  Future<T> delete<T>(String path, {Object? data}) => _run(() => dio.delete<T>(path, data: data));
  Future<T> upload<T>(String path, MultipartFile file) => _run(() => dio.post<T>(path, data: FormData.fromMap({'file': file})));

  Future<T> _run<T>(Future<Response<T>> Function() call) async {
    try {
      return (await call()).data as T;
    } on DioException catch (e) {
      throw ApiError.fromDio(e);
    }
  }
}
