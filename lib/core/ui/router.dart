import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/change_password_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/customer/customer_shell.dart';
import '../../features/customer/screens.dart';
import '../../features/merchant/merchant_shell.dart';
import '../../features/merchant/screens.dart';
import '../auth/auth_controller.dart';
import '../lock/lock_settings_screen.dart';

/// Route guards mirror the web app: anonymous → /auth, forced password change → /change-password,
/// merchants land on /merchant, customers on /home. The API is the real authority.
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _AuthListenable(ref);
  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final loc = state.matchedLocation;
      final isAuthRoute = loc == '/auth' || loc.startsWith('/register') || loc == '/forgot-password';
      if (auth.status == AuthStatus.loading) return loc == '/' ? null : '/';
      if (auth.status == AuthStatus.anon) return isAuthRoute ? null : '/auth';
      final me = auth.me!;
      if (me.forcePasswordChange) return loc == '/change-password' ? null : '/change-password';
      if (loc == '/' || isAuthRoute || loc == '/change-password') return me.home;
      if (loc.startsWith('/merchant') && !me.isMerchant) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const _Splash()),
      GoRoute(path: '/auth', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/register/:type', builder: (_, s) => RegisterScreen(userType: s.pathParameters['type'])),
      GoRoute(path: '/change-password', builder: (_, __) => const ChangePasswordScreen()),
      GoRoute(path: '/settings/lock', builder: (_, __) => const LockSettingsScreen()),
      ShellRoute(
        builder: (_, __, child) => CustomerShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/store/:id', builder: (_, s) => StoreScreen(storeId: s.pathParameters['id']!)),
          GoRoute(path: '/cart', builder: (_, __) => const CartScreen()),
          GoRoute(path: '/orders', builder: (_, __) => const OrdersScreen()),
          GoRoute(path: '/credit', builder: (_, __) => const CreditScreen()),
          GoRoute(path: '/wallet', builder: (_, __) => const WalletScreen()),
          GoRoute(path: '/favorites', builder: (_, __) => const FavoritesScreen()),
          GoRoute(path: '/locations', builder: (_, __) => const LocationsScreen()),
          GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),
      ShellRoute(
        builder: (_, __, child) => MerchantShell(child: child),
        routes: [
          GoRoute(path: '/merchant', builder: (_, __) => const MerchantDashboardScreen()),
          GoRoute(path: '/merchant/pos', builder: (_, __) => const PosScreen()),
          GoRoute(path: '/merchant/orders', builder: (_, __) => const MerchantOrdersScreen()),
          GoRoute(path: '/merchant/products', builder: (_, __) => const MerchantProductsScreen()),
          GoRoute(path: '/merchant/returns', builder: (_, __) => const MerchantReturnsScreen()),
          GoRoute(path: '/merchant/reports', builder: (_, __) => const MerchantReportsScreen()),
          GoRoute(path: '/merchant/credit', builder: (_, __) => const MerchantCreditScreen()),
          GoRoute(path: '/merchant/settings', builder: (_, __) => const MerchantSettingsScreen()),
        ],
      ),
    ],
  );
});

class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen(authControllerProvider, (_, __) => notifyListeners());
  }
}

class _Splash extends StatelessWidget {
  const _Splash();
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: CircularProgressIndicator()));
}
