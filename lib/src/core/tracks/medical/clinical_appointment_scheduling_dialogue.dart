class ClinicalAppointmentSchedulingDialogue {
  const ClinicalAppointmentSchedulingDialogue();
  String schedulePrompt(String lang, String date) => lang == 'ar' ? 'تم تأكيد موعدك يوم $date.' : 'Appointment confirmed for $date.';
}
