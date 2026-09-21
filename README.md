# wasl_mobile

Flutter app for Wasl (وصل) customers and merchants (admin stays on the web). Talks to `wasl-api` only.

```bash
export PATH=$HOME/sdks/bin:$HOME/sdks/flutter/bin:$PATH   # local SDK (see wasl-ops/MIGRATION-LOG.md)
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # drift codegen
flutter analyze && flutter test
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api   # Android emulator → local API
```

- `lib/core/api` – dio client (`X-Client: mobile`, queued refresh on 401), `ApiError` with the Arabic code dictionary.
- `lib/core/auth` – refresh token in secure storage, access token in memory, `Me` mirror of `/auth/me`, `AuthController`.
- `lib/core/ui/router.dart` – go_router with the same guards as the web (anon → `/auth`, forced password change, merchant-first home).
- `lib/core/lock` – device PIN lock (port of the web `app-lock.ts`), `lib/core/events` – SSE client, `lib/core/db` – drift tables for the offline POS, `lib/core/sync` – outbox replay engine.
- `lib/features/customer`, `lib/features/merchant` – screens; `lib/core/l10n/app_ar.arb` – strings.
- Release builds: `.github/workflows/flutter-apk.yml` (same keystore secrets as the old Capacitor workflow, `applicationId ye.wasl.app` so it installs over the old APK).
