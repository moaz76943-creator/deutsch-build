import 'package:flutter/foundation.dart';

import 'anmeldung_models.dart';
import 'anmeldung_phrase_bank.dart';

final class AnmeldungAppointmentsAgent extends ChangeNotifier {
  RegistrationAction _registrationAction = RegistrationAction.all;
  AppointmentAction _appointmentAction = AppointmentAction.all;
  String _query = '';

  RegistrationAction get registrationAction => _registrationAction;
  AppointmentAction get appointmentAction => _appointmentAction;
  String get query => _query;

  List<AnmeldungPhrase> get allPhrases =>
      List<AnmeldungPhrase>.unmodifiable(AnmeldungPhraseBank.all);

  List<AnmeldungPhrase> get visiblePhrases {
    return List<AnmeldungPhrase>.unmodifiable(
      AnmeldungPhraseBank.all.where((phrase) {
        final registrationMatches =
            _registrationAction == RegistrationAction.all ||
                phrase.registrationAction == _registrationAction;
        final appointmentMatches =
            _appointmentAction == AppointmentAction.all ||
                phrase.appointmentAction == _appointmentAction;
        return registrationMatches &&
            appointmentMatches &&
            phrase.matches(_query);
      }),
    );
  }

  String get preparationNoteDe =>
      'Welche Unterlagen, Fristen und Buchungswege gelten, kann örtlich und je nach Anliegen variieren. Vor dem Termin die Angaben der zuständigen Meldebehörde prüfen.';

  String get preparationNoteAr =>
      'قد تختلف المستندات والمواعيد وطريقة الحجز حسب المدينة ونوع المعاملة. تحقق من تعليمات دائرة التسجيل المختصة قبل الموعد.';

  void setRegistrationAction(RegistrationAction value) {
    if (_registrationAction == value) return;
    _registrationAction = value;
    notifyListeners();
  }

  void setAppointmentAction(AppointmentAction value) {
    if (_appointmentAction == value) return;
    _appointmentAction = value;
    notifyListeners();
  }

  void setQuery(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }

  void clearFilters() {
    if (_registrationAction == RegistrationAction.all &&
        _appointmentAction == AppointmentAction.all &&
        _query.isEmpty) {
      return;
    }
    _registrationAction = RegistrationAction.all;
    _appointmentAction = AppointmentAction.all;
    _query = '';
    notifyListeners();
  }
}
