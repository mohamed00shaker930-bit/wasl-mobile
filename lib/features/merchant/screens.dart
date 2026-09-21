import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_error.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/ui/widgets.dart';

class _Todo extends StatelessWidget {
  const _Todo(this.title);
  final String title;
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(title)), body: Center(child: Text('$title — قيد الإنشاء')));
}

/// GET /merchant/dashboard tiles (same numbers as merchant.index.tsx).
final dashboardProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) => ref.watch(apiClientProvider).get<Map<String, dynamic>>('/merchant/dashboard'));

class MerchantDashboardScreen extends ConsumerWidget {
  const MerchantDashboardScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final d = ref.watch(dashboardProvider);
    final store = ref.watch(authControllerProvider).me?.store;
    return Scaffold(
      appBar: AppBar(title: Text(store?['name'] as String? ?? 'لوحة التاجر')),
      body: d.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorRetry(message: e is ApiError ? e.message : e.toString(), onRetry: () => ref.invalidate(dashboardProvider)),
        data: (m) => GridView.count(
          crossAxisCount: 2, padding: const EdgeInsets.all(12), mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.6,
          children: [
            _Tile('طلبات جديدة', '${m['new_orders']}'),
            _Tile('طلبات اليوم', '${m['today_orders']}'),
            _Tile('مبيعات اليوم', fmtRial((m['today_revenue'] as num?) ?? 0)),
            _Tile('أجل مستحق', fmtRial((m['credit_outstanding'] as num?) ?? 0)),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.label, this.value);
  final String label, value;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(label, style: Theme.of(context).textTheme.bodySmall), const SizedBox(height: 6), Text(value, style: Theme.of(context).textTheme.titleLarge)])));
}

class PosScreen extends StatelessWidget { const PosScreen({super.key}); @override Widget build(BuildContext c) => const _Todo('نقطة البيع'); }
class MerchantOrdersScreen extends StatelessWidget { const MerchantOrdersScreen({super.key}); @override Widget build(BuildContext c) => const _Todo('الطلبات'); }
class MerchantProductsScreen extends StatelessWidget { const MerchantProductsScreen({super.key}); @override Widget build(BuildContext c) => const _Todo('المنتجات'); }
class MerchantReturnsScreen extends StatelessWidget { const MerchantReturnsScreen({super.key}); @override Widget build(BuildContext c) => const _Todo('المرتجعات'); }
class MerchantReportsScreen extends StatelessWidget { const MerchantReportsScreen({super.key}); @override Widget build(BuildContext c) => const _Todo('التقارير'); }
class MerchantCreditScreen extends StatelessWidget { const MerchantCreditScreen({super.key}); @override Widget build(BuildContext c) => const _Todo('الأجل'); }
class MerchantSettingsScreen extends StatelessWidget { const MerchantSettingsScreen({super.key}); @override Widget build(BuildContext c) => const _Todo('المتجر'); }
