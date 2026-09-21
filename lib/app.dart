import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/auth/auth_controller.dart';
import 'core/events/sse_client.dart';
import 'core/lock/lock_gate.dart';
import 'core/l10n/app_localizations.dart';
import 'core/ui/router.dart';
import 'core/ui/theme.dart';

class WaslApp extends ConsumerStatefulWidget {
  const WaslApp({super.key});
  @override
  ConsumerState<WaslApp> createState() => _WaslAppState();
}

class _WaslAppState extends ConsumerState<WaslApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(authControllerProvider.notifier).bootstrap());
    // live updates only while signed in
    ref.listenManual(authControllerProvider, (_, next) {
      final sse = ref.read(sseProvider);
      next.status == AuthStatus.authed ? sse.start() : sse.stop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'وصل',
      debugShowCheckedModeBanner: false,
      theme: waslTheme(),
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
      builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: LockGate(child: child ?? const SizedBox())),
      routerConfig: router,
    );
  }
}
