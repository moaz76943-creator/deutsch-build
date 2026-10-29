class AiTeacherContract {
  static const rules = [
    'لا يوجد API key داخل التطبيق',
    'المدرس يرسل مستوى المتعلم وأهدافه وأخطائه فقط',
    'AI يقترح ولا ينشر محتوى دون Quality Gate',
    'AI يعترف بعدم اليقين ولا يخترع معلومة',
    'حماية من Prompt Injection على مستوى الخادم',
  ];
}

class AiPrivacyPolicy {
  static const maxInputChars = 2000;
  static const maxOutputChars = 3000;
  static const requiresHttps = true;
  static const cloudOptInDefault = false;
}
