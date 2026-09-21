import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_error.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/ui/widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;

  Future<void> _submit() async {
    final t = AppLocalizations.of(context)!;
    if (_busy) return;
    if (_phone.text.trim().isEmpty || _password.text.isEmpty) {
      showToast(context, t.enterPhoneAndPassword, error: true);
      return;
    }
    setState(() => _busy = true);
    try {
      // the account-status gate is enforced by the API; codes map to Arabic text in ApiError
      await ref.read(authControllerProvider.notifier).login(_phone.text.trim(), _password.text);
      if (mounted) showToast(context, t.loggedIn);
    } on ApiError catch (e) {
      if (mounted) showToast(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  const BrandHeader(),
                  const SizedBox(height: 24),
                  TextField(controller: _phone, keyboardType: TextInputType.phone, textDirection: TextDirection.ltr, maxLength: 9,
                      decoration: InputDecoration(labelText: t.phone, prefixIcon: const Icon(Icons.phone), counterText: '')),
                  const SizedBox(height: 12),
                  TextField(controller: _password, obscureText: true, textDirection: TextDirection.ltr, onSubmitted: (_) => _submit(),
                      decoration: InputDecoration(labelText: t.password, prefixIcon: const Icon(Icons.lock))),
                  const SizedBox(height: 20),
                  FilledButton(onPressed: _busy ? null : _submit, child: Text(_busy ? t.loggingIn : t.login)),
                  const SizedBox(height: 8),
                  OutlinedButton(onPressed: () => context.push('/register'), child: Text(t.createAccount)),
                  TextButton(onPressed: () => context.push('/forgot-password'), child: Text(t.forgotPassword)),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
