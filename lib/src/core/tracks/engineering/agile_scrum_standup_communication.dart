class AgileScrumStandupCommunication {
  const AgileScrumStandupCommunication();
  String standupReport(String lang, String completed, String blocker) {
    if (lang == 'ar') return 'أنهيت أمس: $completed. لا توجد أي عوائق حالياً: $blocker.';
    return 'Completed yesterday: $completed. No current blockers: $blocker.';
  }
}
