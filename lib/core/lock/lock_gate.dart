import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import 'pin_lock.dart';

/// Wraps the router: shows the PIN screen over everything while locked; records activity on any tap.
class LockGate extends ConsumerStatefulWidget {
  const LockGate({super.key, required this.child});
  final Widget child;
  @override
  ConsumerState<LockGate> createState() => _LockGateState();
}

class _LockGateState extends ConsumerState<LockGate> {
  Timer? _idle;
  @override
  void initState() {
    super.initState();
    _idle = Timer.periodic(const Duration(seconds: 30), (_) => ref.read(pinLockProvider.notifier).checkIdle());
  }

  @override
  void dispose() {
    _idle?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lock = ref.watch(pinLockProvider);
    final authed = ref.watch(authControllerProvider).status == AuthStatus.authed;
    return Listener(
      onPointerDown: (_) => ref.read(pinLockProvider.notifier).markActive(),
      child: Stack(children: [
        widget.child,
        if (lock.locked && authed) const Positioned.fill(child: _PinScreen()),
      ]),
    );
  }
}

class _PinScreen extends ConsumerStatefulWidget {
  const _PinScreen();
  @override
  ConsumerState<_PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends ConsumerState<_PinScreen> {
  String _pin = '';
  bool _error = false;

  Future<void> _press(String d) async {
    if (_pin.length >= pinLength) return;
    setState(() { _pin += d; _error = false; });
    if (_pin.length == pinLength) {
      final ok = await ref.read(pinLockProvider.notifier).verify(_pin);
      if (!ok && mounted) setState(() { _pin = ''; _error = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      child: SafeArea(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.lock, size: 48, color: scheme.primary),
          const SizedBox(height: 12),
          const Text('أدخل رمز القفل', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (var i = 0; i < pinLength; i++)
              Container(width: 16, height: 16, margin: const EdgeInsets.all(6), decoration: BoxDecoration(shape: BoxShape.circle, color: i < _pin.length ? scheme.primary : scheme.outlineVariant)),
          ]),
          if (_error) const Padding(padding: EdgeInsets.only(top: 8), child: Text('رمز غير صحيح', style: TextStyle(color: Colors.red))),
          const SizedBox(height: 24),
          for (final row in ['123', '456', '789', ' 0⌫'])
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              for (final ch in row.characters)
                SizedBox(
                  width: 84, height: 64,
                  child: ch == ' ' ? null : TextButton(
                    onPressed: () => ch == '⌫' ? setState(() => _pin = _pin.isEmpty ? '' : _pin.substring(0, _pin.length - 1)) : _press(ch),
                    child: Text(ch, style: const TextStyle(fontSize: 26)),
                  ),
                ),
            ]),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () async {
              // like the web: forgetting the PIN clears it and signs out
              await ref.read(pinLockProvider.notifier).clearPin();
              await ref.read(authControllerProvider.notifier).logout();
            },
            child: const Text('نسيت الرمز؟ تسجيل الخروج'),
          ),
        ]),
      ),
    );
  }
}
