import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_error.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/ui/widgets.dart';

/// `/register` chooses the type; `/register/customer|merchant` shows the form. POST /auth/register → pending approval.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key, this.userType});
  final String? userType;
  @override
  ConsumerState<RegisterScreen> createState() => _State();
}

class _State extends ConsumerState<RegisterScreen> {
  final _c = {for (final k in ['phone', 'password', 'confirm', 'name', 'city', 'district', 'address', 'business_name']) k: TextEditingController()};
  List<Map<String, dynamic>> _categories = [];
  String? _categoryId;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (widget.userType == 'merchant') {
      ref.read(apiClientProvider).get<List<dynamic>>('/business-categories').then((r) => setState(() => _categories = r.cast<Map<String, dynamic>>())).catchError((_) {});
    }
  }

  Future<void> _submit() async {
    final t = AppLocalizations.of(context)!;
    if (_c['password']!.text != _c['confirm']!.text) return showToast(context, t.passwordMismatch, error: true);
    setState(() => _busy = true);
    try {
      await ref.read(apiClientProvider).post('/auth/register', data: {
        'phone': _c['phone']!.text.trim(), 'password': _c['password']!.text, 'name': _c['name']!.text.trim(), 'user_type': widget.userType,
        if (_c['city']!.text.isNotEmpty) 'city': _c['city']!.text.trim(), if (_c['district']!.text.isNotEmpty) 'district': _c['district']!.text.trim(),
        if (_c['address']!.text.isNotEmpty) 'address': _c['address']!.text.trim(),
        if (widget.userType == 'merchant') 'business_name': _c['business_name']!.text.trim(), if (_categoryId != null) 'business_category_id': _categoryId,
      });
      if (!mounted) return;
      showToast(context, t.awaitingApproval);
      context.go('/auth');
    } on ApiError catch (e) {
      if (mounted) showToast(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    if (widget.userType == null) {
      return Scaffold(
        appBar: AppBar(title: Text(t.createAccount)),
        body: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
          FilledButton.icon(onPressed: () => context.push('/register/customer'), icon: const Icon(Icons.person), label: Text(t.customer)),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(onPressed: () => context.push('/register/merchant'), icon: const Icon(Icons.storefront), label: Text(t.merchant)),
        ])),
      );
    }
    final merchant = widget.userType == 'merchant';
    return Scaffold(
      appBar: AppBar(title: Text(merchant ? 'حساب تاجر' : 'حساب عميل')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        TextField(controller: _c['name'], decoration: const InputDecoration(labelText: 'الاسم')),
        const SizedBox(height: 12),
        TextField(controller: _c['phone'], keyboardType: TextInputType.phone, textDirection: TextDirection.ltr, maxLength: 9, decoration: InputDecoration(labelText: t.phone, counterText: '')),
        const SizedBox(height: 12),
        if (merchant) ...[
          TextField(controller: _c['business_name'], decoration: const InputDecoration(labelText: 'اسم النشاط التجاري')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(initialValue: _categoryId, decoration: const InputDecoration(labelText: 'نوع النشاط'),
              items: _categories.map((c) => DropdownMenuItem(value: c['id'] as String, child: Text(c['nameAr'] as String))).toList(), onChanged: (v) => setState(() => _categoryId = v)),
          const SizedBox(height: 12),
        ],
        TextField(controller: _c['city'], decoration: const InputDecoration(labelText: 'المدينة')),
        const SizedBox(height: 12),
        TextField(controller: _c['district'], decoration: const InputDecoration(labelText: 'الحي')),
        const SizedBox(height: 12),
        TextField(controller: _c['address'], decoration: const InputDecoration(labelText: 'العنوان')),
        const SizedBox(height: 12),
        TextField(controller: _c['password'], obscureText: true, decoration: InputDecoration(labelText: t.password)),
        const SizedBox(height: 12),
        TextField(controller: _c['confirm'], obscureText: true, decoration: InputDecoration(labelText: t.confirmPassword)),
        const SizedBox(height: 20),
        FilledButton(onPressed: _busy ? null : _submit, child: Text(t.createAccount)),
      ]),
    );
  }
}
