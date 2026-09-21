import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';

/// Same eight entries as MerchantShell.tsx, rendered as a scrollable bottom bar.
class MerchantShell extends StatelessWidget {
  const MerchantShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final loc = GoRouterState.of(context).matchedLocation;
    final items = [
      ('/merchant', Icons.dashboard_outlined, t.merchantDashboard),
      ('/merchant/pos', Icons.point_of_sale, t.sell),
      ('/merchant/orders', Icons.receipt_long_outlined, t.orders),
      ('/merchant/products', Icons.inventory_2_outlined, t.products),
      ('/merchant/returns', Icons.assignment_return_outlined, t.returns),
      ('/merchant/reports', Icons.bar_chart, t.reports),
      ('/merchant/credit', Icons.book_outlined, t.credit),
      ('/merchant/settings', Icons.storefront_outlined, t.store),
    ];
    return Scaffold(
      body: child,
      bottomNavigationBar: SafeArea(
        child: SizedBox(
          height: 64,
          child: ListView(scrollDirection: Axis.horizontal, children: [
            for (final (path, icon, label) in items)
              InkWell(
                onTap: () => context.go(path),
                child: Container(
                  width: 78, alignment: Alignment.center,
                  decoration: BoxDecoration(border: Border(top: BorderSide(color: loc == path ? Theme.of(context).colorScheme.primary : Colors.transparent, width: 3))),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 22), Text(label, style: const TextStyle(fontSize: 11))]),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}
