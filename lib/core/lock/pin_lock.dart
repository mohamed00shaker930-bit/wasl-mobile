import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Port of the web app's app-lock.ts: 4-digit PIN, sha256(salt + pin), device-local only (never touches the API).
/// Triggers: on launch after the grace period, idle timeout, and returning from background ("hide" lock).
class PinLockSettings {
  const PinLockSettings({this.enabled = false, this.pinSet = false, this.graceMinutes = 10, this.idleLock = true, this.hideLock = true});
  final bool enabled, pinSet, idleLock, hideLock;
  final int graceMinutes;
  PinLockSettings copyWith({bool? enabled, bool? pinSet, int? graceMinutes, bool? idleLock, bool? hideLock}) =>
      PinLockSettings(enabled: enabled ?? this.enabled, pinSet: pinSet ?? this.pinSet, graceMinutes: graceMinutes ?? this.graceMinutes, idleLock: idleLock ?? this.idleLock, hideLock: hideLock ?? this.hideLock);
}

/// Same list as LOCK_DURATIONS in app-lock.ts (0 = every entry).
const lockDurations = [0, 10, 30, 60, 180, 480];
const pinLength = 4;

class PinLockState {
  const PinLockState({required this.settings, required this.locked});
  final PinLockSettings settings;
  final bool locked;
}

final pinLockProvider = StateNotifierProvider<PinLockController, PinLockState>((ref) => PinLockController());

class PinLockController extends StateNotifier<PinLockState> with WidgetsBindingObserver {
  PinLockController([FlutterSecureStorage? storage])
      : _s = storage ?? const FlutterSecureStorage(),
        super(const PinLockState(settings: PinLockSettings(), locked: false)) {
    WidgetsBinding.instance.addObserver(this);
    _load();
  }
  final FlutterSecureStorage _s;
  DateTime _lastActive = DateTime.now();
  static const _k = ('pin_hash', 'pin_salt', 'lock_enabled', 'lock_grace', 'lock_idle', 'lock_hide', 'lock_last_active', 'locked');

  Future<void> _load() async {
    final m = <String, String?>{};
    for (final k in [_k.$1, _k.$2, _k.$3, _k.$4, _k.$5, _k.$6, _k.$7, _k.$8]) {
      m[k] = await _s.read(key: k);
    }
    final settings = PinLockSettings(
      enabled: m[_k.$3] == '1', pinSet: m[_k.$1] != null, graceMinutes: int.tryParse(m[_k.$4] ?? '') ?? 10,
      idleLock: m[_k.$5] != '0', hideLock: m[_k.$6] != '0',
    );
    final last = DateTime.tryParse(m[_k.$7] ?? '');
    final expired = settings.graceMinutes == 0 || last == null || DateTime.now().difference(last).inMinutes >= settings.graceMinutes;
    state = PinLockState(settings: settings, locked: settings.enabled && settings.pinSet && (m[_k.$8] == '1' || expired));
  }

  String _hash(String pin, String salt) => sha256.convert(utf8.encode(salt + pin)).toString();

  Future<void> setPin(String pin) async {
    final salt = base64Url.encode(List<int>.generate(16, (_) => Random.secure().nextInt(256)));
    await _s.write(key: _k.$2, value: salt);
    await _s.write(key: _k.$1, value: _hash(pin, salt));
    await _s.write(key: _k.$3, value: '1');
    state = PinLockState(settings: state.settings.copyWith(pinSet: true, enabled: true), locked: false);
  }

  Future<bool> verify(String pin) async {
    final salt = await _s.read(key: _k.$2), hash = await _s.read(key: _k.$1);
    if (salt == null || hash == null) return true;
    final ok = _hash(pin, salt) == hash;
    if (ok) await unlock();
    return ok;
  }

  Future<void> clearPin() async {
    for (final k in [_k.$1, _k.$2, _k.$8]) {
      await _s.delete(key: k);
    }
    await _s.write(key: _k.$3, value: '0');
    state = PinLockState(settings: state.settings.copyWith(pinSet: false, enabled: false), locked: false);
  }

  Future<void> update({bool? enabled, int? graceMinutes, bool? idleLock, bool? hideLock}) async {
    if (enabled != null) await _s.write(key: _k.$3, value: enabled ? '1' : '0');
    if (graceMinutes != null) await _s.write(key: _k.$4, value: '$graceMinutes');
    if (idleLock != null) await _s.write(key: _k.$5, value: idleLock ? '1' : '0');
    if (hideLock != null) await _s.write(key: _k.$6, value: hideLock ? '1' : '0');
    state = PinLockState(settings: state.settings.copyWith(enabled: enabled, graceMinutes: graceMinutes, idleLock: idleLock, hideLock: hideLock), locked: state.locked);
  }

  Future<void> lock() async {
    if (!state.settings.enabled || !state.settings.pinSet) return;
    await _s.write(key: _k.$8, value: '1');
    state = PinLockState(settings: state.settings, locked: true);
  }

  Future<void> unlock() async {
    await _s.write(key: _k.$8, value: '0');
    await markActive();
    state = PinLockState(settings: state.settings, locked: false);
  }

  Future<void> markActive() async {
    _lastActive = DateTime.now();
    await _s.write(key: _k.$7, value: _lastActive.toIso8601String());
  }

  /// Called by the idle ticker; locks when no interaction for the grace period.
  void checkIdle() {
    final s = state.settings;
    if (!s.enabled || !s.idleLock || s.graceMinutes == 0 || state.locked) return;
    if (DateTime.now().difference(_lastActive).inMinutes >= s.graceMinutes) lock();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && this.state.settings.hideLock) lock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
