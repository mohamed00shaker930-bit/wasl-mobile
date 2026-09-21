// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'وصل';

  @override
  String get tagline => 'بقالة الحي في جوالك';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get loggingIn => 'جاري الدخول...';

  @override
  String get phone => 'رقم الجوال';

  @override
  String get password => 'كلمة المرور';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get forgotPassword => 'نسيت كلمة المرور';

  @override
  String get enterPhoneAndPassword => 'أدخل رقم الجوال وكلمة المرور';

  @override
  String get loggedIn => 'تم تسجيل الدخول';

  @override
  String get home => 'الرئيسية';

  @override
  String get cart => 'السلة';

  @override
  String get myOrders => 'طلباتي';

  @override
  String get credit => 'الأجل';

  @override
  String get account => 'حسابي';

  @override
  String get merchantDashboard => 'لوحة التاجر';

  @override
  String get sell => 'بيع';

  @override
  String get orders => 'الطلبات';

  @override
  String get products => 'منتجات';

  @override
  String get returns => 'مرتجعات';

  @override
  String get reports => 'تقارير';

  @override
  String get store => 'المتجر';

  @override
  String get wallet => 'المحفظة';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get favorites => 'المفضلة';

  @override
  String get locations => 'عناويني';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get currentPassword => 'كلمة المرور الحالية';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get passwordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get passwordTooShort => 'كلمة المرور 6 أحرف على الأقل';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get offline => 'غير متصل';

  @override
  String get online => 'متصل';

  @override
  String pendingSync(int count) {
    return '$count فاتورة بانتظار المزامنة';
  }

  @override
  String get syncNow => 'مزامنة الآن';

  @override
  String get rial => 'ر.ي';

  @override
  String get customer => 'عميل';

  @override
  String get merchant => 'تاجر';

  @override
  String get awaitingApproval => 'تم إرسال طلبك، بانتظار موافقة الإدارة.';
}
