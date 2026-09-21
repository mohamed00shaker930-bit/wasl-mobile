import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void showToast(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message), backgroundColor: error ? Colors.red.shade700 : null, behavior: SnackBarBehavior.floating));
}

class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(children: [
      Container(width: 64, height: 64, decoration: BoxDecoration(color: scheme.primary, borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.shopping_basket, color: Colors.white, size: 34)),
      const SizedBox(height: 10),
      const Text('وصل', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      Text('بقالة الحي في جوالك', style: TextStyle(color: scheme.outline)),
    ]);
  }
}

/// Money formatting identical to the web app's fmtRial (Latin digits, ر.ي suffix).
String fmtRial(num n) => '${NumberFormat('#,##0.##', 'en').format(n)} ر.ي';

/// Wraps a future/stream error into a retry card.
class ErrorRetry extends StatelessWidget {
  const ErrorRetry({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton.tonal(onPressed: onRetry, child: const Text('إعادة المحاولة')),
        ]),
      );
}
