class AppFeature {
  final String name, note;
  final bool active;
  const AppFeature(this.name, this.note, this.active);
}

const featureRegistry = <AppFeature>[
  AppFeature('المفردات المصنفة', 'عشرات الأقسام المنفصلة للكلمات.', true),
  AppFeature('تصريف الأفعال', 'تصريف الأفعال مع مثال وترجمة لكل ضمير.', true),
  AppFeature(
    'البحث والقاموس',
    'بحث عربي/ألماني + تفاصيل الكلمة والجملة + TTS',
    true,
  ),
  AppFeature('النطق والاستماع', 'TTS ألماني للكلمات والجمل', true),
  AppFeature(
    'SRS والمراجعة المتباعدة',
    'اختيار العناصر المستحقة حسب أداء المتعلم',
    true,
  ),
  AppFeature('المدرس المتكيف', 'Next Best Action مبني على المحاولات', true),
  AppFeature('الاختبارات المتدرجة', 'تعرّف واستماع وإنتاج ونقل واحتفاظ', true),
  AppFeature('تصحيح الكتابة الأساسي', 'فحص محلي لأخطاء أساسية', true),
  AppFeature('المحادثة والمواقف', 'مواقف ألمانية واقعية للتدرب', true),
  AppFeature('الإحصائيات والتقرير', 'مهارات ومحاولات وتقرير أسبوعي', true),
  AppFeature('Offline', 'المحتوى والتقدم وTTS محليًا', true),
  AppFeature(
    'واجهة الوصول السهل',
    'أهداف لمس واضحة وتسميات وألوان Material 3 قابلة للوصول',
    true,
  ),
  AppFeature('تركيز اليوم', 'هدف يومي مع دقة وعناصر مستحقة للمراجعة', true),
  AppFeature(
    'مزامنة سحابية',
    'غير مفعلة افتراضيًا؛ تحتاج Backend وحسابًا آمنًا.',
    false,
  ),
  AppFeature(
    'Speech-to-Text',
    'مفعّل عبر محرك الجهاز، مع احترام إعداد الخصوصية.',
    true,
  ),
  AppFeature(
    'AI سحابي',
    'طبقة HTTPS اختيارية؛ لا تعمل دون Endpoint آمن وموافقة المستخدم.',
    true,
  ),
  AppFeature('APK/Android QA', 'يتطلب بناء Android فعليًا واختبار جهاز', false),
  AppFeature(
    'السكن والإيجار',
    'عقد الإيجار والتكاليف ومحضر التسليم والبلاغ عن العيوب.',
    true,
  ),
];
