class ClinicalEmpathyPacer {
  const ClinicalEmpathyPacer();
  String generateComfortingPrompt(String lang) => lang == 'ar' ? 'نحن هنا لمساعدتك، لا تقلق.' : 'We are here to help you.';
}
