import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';

/// Server-sent events from GET /api/events (replaces Supabase Realtime). One connection while the app is
/// in the foreground; reconnects with backoff. Consumers filter on `type` (notification.created, order.updated, …).
class AppEvent {
  AppEvent(this.type, this.data);
  final String type;
  final Map<String, dynamic> data;
}

final sseProvider = Provider<SseClient>((ref) {
  final c = SseClient(ref);
  ref.onDispose(c.dispose);
  return c;
});

class SseClient {
  SseClient(this._ref);
  final Ref _ref;
  final _controller = StreamController<AppEvent>.broadcast();
  CancelToken? _cancel;
  bool _running = false;

  Stream<AppEvent> get stream => _controller.stream;

  void start() {
    if (_running) return;
    _running = true;
    _loop();
  }

  void stop() {
    _running = false;
    _cancel?.cancel();
  }

  void dispose() {
    stop();
    _controller.close();
  }

  Future<void> _loop() async {
    var delay = 2;
    while (_running) {
      final api = _ref.read(apiClientProvider);
      final token = _ref.read(tokenStoreProvider).accessToken;
      if (token == null) { await Future.delayed(const Duration(seconds: 5)); continue; }
      _cancel = CancelToken();
      try {
        final res = await api.dio.get<ResponseBody>('/events', options: Options(responseType: ResponseType.stream, headers: {'Accept': 'text/event-stream'}, receiveTimeout: Duration.zero), cancelToken: _cancel);
        delay = 2;
        String? event;
        final buf = StringBuffer();
        await for (final chunk in res.data!.stream.map((Uint8List d) => utf8.decode(d))) {
          buf.write(chunk);
          var text = buf.toString();
          int idx;
          while ((idx = text.indexOf('\n\n')) >= 0) {
            final block = text.substring(0, idx);
            text = text.substring(idx + 2);
            String? data;
            for (final line in block.split('\n')) {
              if (line.startsWith('event:')) event = line.substring(6).trim();
              if (line.startsWith('data:')) data = line.substring(5).trim();
            }
            if (event != null && event != 'ping' && data != null) {
              try { _controller.add(AppEvent(event, jsonDecode(data) as Map<String, dynamic>)); } catch (_) {}
            }
            event = null;
          }
          buf..clear()..write(text);
        }
      } on DioException catch (e) {
        if (e.response?.statusCode == 401) await api.refresh();
      } catch (_) {}
      if (!_running) break;
      await Future.delayed(Duration(seconds: delay));
      delay = (delay * 2).clamp(2, 30);
    }
  }
}
