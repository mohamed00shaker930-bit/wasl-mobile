import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_error.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/ui/widgets.dart';

/// GET /stores (active, sorted by rating; by distance when a location is known).
final storesProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final r = await ref.watch(apiClientProvider).get<List<dynamic>>('/stores');
  return r.cast<Map<String, dynamic>>();
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stores = ref.watch(storesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('وصل'), actions: [IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () => context.push('/notifications'))]),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(storesProvider.future),
        child: stores.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ErrorRetry(message: e is ApiError ? e.message : e.toString(), onRetry: () => ref.invalidate(storesProvider)),
          data: (list) => ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final s = list[i];
              final dist = s['distanceKm'];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text((s['name'] as String).characters.first)),
                  title: Text(s['name'] as String),
                  subtitle: Text([s['area'], if (dist != null) '${(dist as num).toStringAsFixed(1)} كم', if (s['deliveryInfo'] != null) s['deliveryInfo']].whereType<String>().join(' • ')),
                  trailing: Chip(label: Text(s['isOpen'] == true ? 'مفتوح' : 'مغلق'), backgroundColor: s['isOpen'] == true ? Colors.green.shade50 : Colors.grey.shade200),
                  onTap: () => context.push('/store/${s['id']}'),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
