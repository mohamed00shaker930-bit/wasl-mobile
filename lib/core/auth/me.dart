/// Mirror of `GET /auth/me`.
class Me {
  Me({required this.id, required this.phone, required this.name, required this.accountStatus, required this.roles, required this.perms, required this.isSuper, required this.isStaff, required this.forcePasswordChange, this.store});
  final String id;
  final String phone;
  final String? name;
  final String accountStatus;
  final List<String> roles;
  final List<String> perms;
  final bool isSuper;
  final bool isStaff;
  final bool forcePasswordChange;
  final Map<String, dynamic>? store;

  bool get isMerchant => roles.contains('merchant');
  bool get isCustomer => roles.contains('customer');
  String? get storeId => store?['id'] as String?;
  /// merchant-first, like the web app.
  String get home => isMerchant ? '/merchant' : '/home';

  factory Me.fromJson(Map<String, dynamic> j) {
    final u = j['user'] as Map<String, dynamic>;
    return Me(
      id: u['id'] as String, phone: u['phone'] as String, name: u['name'] as String?, accountStatus: u['account_status'] as String,
      roles: (j['roles'] as List).cast<String>(), perms: (j['perms'] as List).cast<String>(),
      isSuper: j['super'] as bool, isStaff: j['is_staff'] as bool, forcePasswordChange: u['force_password_change'] as bool,
      store: j['store'] as Map<String, dynamic>?,
    );
  }
}
