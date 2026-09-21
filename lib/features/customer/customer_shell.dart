import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';

/// Same five tabs as CustomerShell.tsx: home, cart, orders, credit, profile.
class CustomerShell extends StatelessWidget {
  const CustomerShell({super.key, required this.child});
  final Widget child;

  static const _tabs = ['/home', '/cart', '/orders', '/credit', '/profile'];

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final loc = GoRouterState.of(context).matchedLocation;
    final index = _tabs.indexWhere((p) => loc == p || (p != '/home' && loc.startsWith(p)));
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index < 0 ? 0 : index,
        onDestinationSelected: (i) => context.go(_tabs[i]),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: t.home),
          NavigationDestination(icon: const Icon(Icons.shopping_basket_outlined), selectedIcon: const Icon(Icons.shopping_basket), label: t.cart),
          NavigationDestination(icon: const Icon(Icons.receipt_long_outlined), selectedIcon: const Icon(Icons.receipt_long), label: t.myOrders),
          NavigationDestination(icon: const Icon(Icons.book_outlined), selectedIcon: const Icon(Icons.book), label: t.credit),
          NavigationDestination(icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person), label: t.account),
        ],
      ),
    );
  }
}
