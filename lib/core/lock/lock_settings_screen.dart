import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ui/widgets.dart';
import 'pin_lock.dart';

/// Settings from profile.tsx: enable, set/change/remove PIN, grace period, idle lock, lock on hide.
class LockSettingsScreen extends ConsumerWidget {
  const LockSettingsScreen({super.key});

  Future<void> _setPin(BuildContext context, WidgetRef ref) async {
    final c1 = TextEditingController(), c2 = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('رمز القفل (4 أرقام)'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: c1, keyboardType: TextInputType.number, maxLength: pinLength, obscureText: true, decoration: const InputDecoration(labelText: 'الرمز')),
          TextField(controller: c2, keyboardType: TextInputType.number, maxLength: pinLength, obscureText: true, decoration: const InputDecoration(labelText: 'تأكيد الرمز')),
        ]),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حفظ'))],
      ),
    );
    if (ok != true) return;
    if (c1.text.length != pinLength || c1.text != c2.text || int.tryParse(c1.text) == null) {
      if (context.mounted) showToast(context, 'الرمز 4 أرقام ويجب أن يتطابق التأكيد', error: true);
      return;
    }
    await ref.read(pinLockProvider.notifier).setPin(c1.text);
    if (context.mounted) showToast(context, 'تم حفظ رمز القفل');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(pinLockProvider).settings;
    final n = ref.read(pinLockProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('قفل التطبيق')),
      body: ListView(children: [
        SwitchListTile(title: const Text('تفعيل قفل التطبيق'), value: s.enabled && s.pinSet, onChanged: (v) => v ? _setPin(context, ref) : n.update(enabled: false)),
        ListTile(title: Text(s.pinSet ? 'تغيير الرمز' : 'تعيين الرمز'), leading: const Icon(Icons.pin), onTap: () => _setPin(context, ref)),
        if (s.pinSet) ListTile(title: const Text('إزالة الرمز'), leading: const Icon(Icons.lock_open), onTap: n.clearPin),
        ListTile(
          title: const Text('مدة السماح قبل طلب الرمز'),
          trailing: DropdownButton<int>(value: s.graceMinutes, items: [for (final m in lockDurations) DropdownMenuItem(value: m, child: Text(m == 0 ? 'كل مرة' : '$m دقيقة'))], onChanged: (v) => n.update(graceMinutes: v)),
        ),
        SwitchListTile(title: const Text('القفل عند عدم الاستخدام'), value: s.idleLock, onChanged: (v) => n.update(idleLock: v)),
        SwitchListTile(title: const Text('القفل عند الخروج من التطبيق'), value: s.hideLock, onChanged: (v) => n.update(hideLock: v)),
      ]),
    );
  }
}
