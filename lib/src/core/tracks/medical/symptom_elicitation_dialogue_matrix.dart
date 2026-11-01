class SymptomElicitationDialogueMatrix {
  const SymptomElicitationDialogueMatrix();
  String getPainScaleQuestion(String lang) {
    if (lang == 'ar') return 'صف شدة الألم من 1 إلى 10.';
    if (lang == 'tr') return 'Ağrınızı 1 ile 10 arasında nasıl derecelendirirsiniz?';
    return 'Please rate your pain on a scale from 1 to 10.';
  }
}
