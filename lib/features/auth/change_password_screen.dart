import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_error.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/ui/widgets.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  ConsumerState<ChangePasswordScreen> createState() => _State();
}

class _State extends ConsumerState<ChangePasswordScreen> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;

  Future<void> _submit() async {
    final t = AppLocalizations.of(context)!;
    final forced = ref.read(authControllerProvider).me?.forcePasswordChange ?? false;
    if (_next.text.length < 6) return showToast(context, t.passwordTooShort, error: true);
    if (_next.text != _confirm.text) return showToast(context, t.passwordMismatch, error: true);
    setState(() => _busy = true);
    try {
      await ref.read(authControllerProvider.notifier).changePassword(current: forced ? null : _current.text, next: _next.text);
    } on ApiError catch (e) {
      if (mounted) showToast(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final forced = ref.watch(authControllerProvider).me?.forcePasswordChange ?? false;
    return Scaffold(
      appBar: AppBar(title: Text(t.changePassword)),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        if (!forced) ...[TextField(controller: _current, obscureText: true, decoration: InputDecoration(labelText: t.currentPassword)), const SizedBox(height: 12)],
        TextField(controller: _next, obscureText: true, decoration: InputDecoration(labelText: t.newPassword)),
        const SizedBox(height: 12),
        TextField(controller: _confirm, obscureText: true, decoration: InputDecoration(labelText: t.confirmPassword)),
        const SizedBox(height: 20),
        FilledButton(onPressed: _busy ? null : _submit, child: Text(t.save)),
      ]),
    );
  }
}
