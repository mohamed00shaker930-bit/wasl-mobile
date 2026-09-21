import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_controller.dart';

class _Todo extends StatelessWidget {
  const _Todo(this.title);
  final String title;
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(title)), body: Center(child: Text('$title — قيد الإنشاء')));
}

class StoreScreen extends StatelessWidget { const StoreScreen({super.key, required this.storeId}); final String storeId; @override Widget build(BuildContext c) => _Todo('المتجر $storeId'); }
class CartScreen extends StatelessWidget { const CartScreen({super.key}); @override Widget build(BuildContext c) => const _Todo('السلة'); }
class OrdersScreen extends StatelessWidget { const OrdersScreen({super.key}); @override Widget build(BuildContext c) => const _Todo('طلباتي'); }
class CreditScreen extends StatelessWidget { const CreditScreen({super.key}); @override Widget build(BuildContext c) => const _Todo('الأجل'); }
class WalletScreen extends StatelessWidget { const WalletScreen({super.key}); @override Widget build(BuildContext c) => const _Todo('المحفظة'); }
class FavoritesScreen extends StatelessWidget { const FavoritesScreen({super.key}); @override Widget build(BuildContext c) => const _Todo('المفضلة'); }
class LocationsScreen extends StatelessWidget { const LocationsScreen({super.key}); @override Widget build(BuildContext c) => const _Todo('عناويني'); }
class NotificationsScreen extends StatelessWidget { const NotificationsScreen({super.key}); @override Widget build(BuildContext c) => const _Todo('الإشعارات'); }

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(authControllerProvider).me;
    return Scaffold(
      appBar: AppBar(title: const Text('حسابي')),
      body: ListView(children: [
        ListTile(leading: const Icon(Icons.person), title: Text(me?.name ?? ''), subtitle: Text(me?.phone ?? '')),
        ListTile(leading: const Icon(Icons.lock), title: const Text('تغيير كلمة المرور'), onTap: () => context.push('/change-password')),
        ListTile(leading: const Icon(Icons.logout), title: const Text('تسجيل الخروج'), onTap: () => ref.read(authControllerProvider.notifier).logout()),
      ]),
    );
  }
}
