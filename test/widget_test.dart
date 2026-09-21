import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wasl_mobile/core/l10n/app_localizations.dart';
import 'package:wasl_mobile/features/auth/login_screen.dart';

Widget wrap(Widget child) => ProviderScope(
      child: MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar')],
        localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
        home: Directionality(textDirection: TextDirection.rtl, child: child),
      ),
    );

void main() {
  testWidgets('login screen renders in Arabic and validates empty input', (tester) async {
    await tester.pumpWidget(wrap(const LoginScreen()));
    await tester.pumpAndSettle();
    expect(find.text('تسجيل الدخول'), findsOneWidget);
    expect(find.text('إنشاء حساب'), findsOneWidget);
    await tester.tap(find.text('تسجيل الدخول'));
    await tester.pump();
    expect(find.text('أدخل رقم الجوال وكلمة المرور'), findsOneWidget);
  });
}
