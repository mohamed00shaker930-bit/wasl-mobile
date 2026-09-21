import 'package:dio/dio.dart';

/// The API answers every failure with `{ "error": "<code>", "details": {...} }`. Arabic text lives here, not on the server.
class ApiError implements Exception {
  ApiError(this.status, this.code, {this.details});
  final int status;
  final String code;
  final Map<String, dynamic>? details;

  bool get isNetwork => status == 0;
  bool get isRetryable => isNetwork || status >= 500;

  String get message => messages[code] ?? 'حدث خطأ غير متوقع';

  static ApiError fromDio(DioException e) {
    final res = e.response;
    if (res == null) return ApiError(0, 'network');
    final data = res.data;
    if (data is Map<String, dynamic>) {
      return ApiError(res.statusCode ?? 0, data['error'] as String? ?? 'internal', details: data['details'] as Map<String, dynamic>?);
    }
    return ApiError(res.statusCode ?? 0, 'internal');
  }

  static const messages = <String, String>{
    'network': 'تعذر الاتصال بالخادم. تحقق من الإنترنت.',
    'invalid_credentials': 'بيانات الدخول غير صحيحة',
    'account_pending': 'حسابك قيد مراجعة الإدارة.',
    'account_rejected': 'تم رفض طلب إنشاء الحساب، يرجى التواصل مع الإدارة.',
    'account_suspended': 'تم إيقاف هذا الحساب، يرجى التواصل مع الإدارة.',
    'account_deleted': 'تم حذف هذا الحساب.',
    'force_password_change': 'يجب تغيير كلمة المرور أولاً',
    'invalid_token': 'انتهت الجلسة، سجّل الدخول من جديد',
    'token_reused': 'انتهت الجلسة، سجّل الدخول من جديد',
    'forbidden': 'غير مصرح لك بهذا الإجراء',
    'not_found': 'العنصر غير موجود',
    'invalid_phone': 'رقم الجوال غير صحيح',
    'weak_password': 'كلمة المرور قصيرة جداً',
    'phone_taken': 'رقم الجوال مسجّل مسبقاً',
    'validation': 'البيانات المدخلة غير صحيحة',
    'store_not_active': 'هذه البقالة غير متاحة حالياً',
    'product_unknown': 'أحد المنتجات لم يعد متوفراً',
    'product_out_of_stock': 'أحد المنتجات نفد من المخزون',
    'wallet_insufficient': 'رصيد المحفظة غير كافٍ',
    'credit_tx_not_pending': 'هذه العملية لم تعد معلّقة',
    'invalid_status_transition': 'لا يمكن تغيير حالة الطلب بهذا الشكل',
    'return_not_allowed': 'لا يمكن طلب إرجاع هذا الطلب',
    'already_rated': 'تم تقييم هذا الطلب مسبقاً',
    'file_too_large': 'حجم الملف كبير جداً',
    'unsupported_file': 'نوع الملف غير مدعوم',
    'rate_limited': 'محاولات كثيرة، انتظر قليلاً',
    'conflict': 'تعارض في البيانات، حدّث الصفحة',
    'internal': 'خطأ في الخادم، حاول لاحقاً',
  };
}
