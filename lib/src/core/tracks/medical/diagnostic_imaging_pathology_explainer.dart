class DiagnosticImagingPathologyExplainer {
  const DiagnosticImagingPathologyExplainer();
  String simplifyResult(String term) => term == 'normal' ? 'النتائج سليمة ومطمئنة' : 'تحتاج لمتابعة مع الطبيب';
}
