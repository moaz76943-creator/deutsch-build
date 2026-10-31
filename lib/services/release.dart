class ReleaseGate {
  final String name;
  final bool passed;
  final String note;
  const ReleaseGate(this.name, this.passed, this.note);
}

// Production builds keep internal quality/release diagnostics hidden by default.
// Developers can opt in explicitly at compile time without granting runtime authority.
const adminToolsEnabled = bool.fromEnvironment(
  'DEUTSCH_ADMIN_TOOLS',
  defaultValue: false,
);
const releaseGates = <ReleaseGate>[
  ReleaseGate(
    'المحتوى',
    false,
    '14,793 مدخلًا حاليًا • V129. فحوص البنية والتكرار والأخطاء المعروفة تمر؛ التدقيق اللغوي البشري الشامل النهائي ما زال مطلوبًا',
  ),
  ReleaseGate(
    'اللغة والعربية',
    false,
    'الفحوص الآلية قوية، لكن المراجعة البشرية الكاملة لم تنتهِ',
  ),
  ReleaseGate(
    'التعلم والتكيف',
    true,
    'المحاولات الفعلية تدخل في قرار المدرس مع SRS محفوظ محليًا وحدود للتخزين؛ ملف المفردة يربط التصريفات والكلمات المرتبطة وحالة المراجعة.',
  ),
  ReleaseGate(
    'الأمان المحلي',
    true,
    'الشبكة اختيارية ومقيدة بـ HTTPS، مع منع النسخ الاحتياطي وFLAG_SECURE والتحقق من المدخلات وR8/Obfuscation في Release.',
  ),
  ReleaseGate(
    'Performance',
    true,
    'تمت إزالة المسح المتكرر للمحاولات لكل عنصر، وتجميع المحاولات مرة واحدة، وتخزين تقرير Content Intelligence مؤقتًا عبر هوية corpus.',
  ),
  ReleaseGate('AI السحابي', false, 'يتطلب Backend آمنًا؛ غير مفعّل عمدًا'),
  ReleaseGate('Speech-to-Text', false, 'التنفيذ الحقيقي غير موجود'),
  ReleaseGate('Cloud Sync', false, 'غير مفعّل عمدًا للحفاظ على خصوصية التطبيق'),
  ReleaseGate('Android QA', false, 'يتطلب بناء Android فعليًا واختبار جهاز'),
  ReleaseGate(
    'Accessibility',
    false,
    'اختبار آلي كامل واختبار قارئ الشاشة مطلوبان قبل إعلان البوابة مكتملة',
  ),
];
