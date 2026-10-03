import '../dentist_models.dart';

final class DentistCheckupAgent {
  const DentistCheckupAgent();

  List<DentistPhrase> get items => const <DentistPhrase>[
        DentistPhrase(
          id: 'dc_regular',
          category: DentistCategory.checkup,
          german: 'Ich bin zur regelmäßigen Kontrolluntersuchung hier.',
          arabic: 'أنا هنا لإجراء الفحص الدوري المنتظم.',
          tags: <String>['Kontrolluntersuchung', 'regelmäßig'],
        ),
        DentistPhrase(
          id: 'dc_pain',
          category: DentistCategory.checkup,
          german: 'Dieser Zahn tut beim Kauen weh.',
          arabic: 'هذا السن يؤلمني عند المضغ.',
          tags: <String>['Zahn', 'Kauen', 'Schmerz'],
        ),
        DentistPhrase(
          id: 'dc_sensitive',
          category: DentistCategory.checkup,
          german: 'Der Zahn ist bei kalten Getränken empfindlich.',
          arabic: 'السن حساس عند المشروبات الباردة.',
          tags: <String>['empfindlich', 'kalt'],
        ),
        DentistPhrase(
          id: 'dc_gums',
          category: DentistCategory.checkup,
          german: 'Mein Zahnfleisch blutet manchmal beim Putzen.',
          arabic: 'تنزف لثتي أحياناً عند تنظيف الأسنان.',
          tags: <String>['Zahnfleisch', 'blutet', 'اللثة'],
        ),
        DentistPhrase(
          id: 'dc_exam_question',
          category: DentistCategory.checkup,
          german: 'Was wird bei der Kontrolle heute untersucht?',
          arabic: 'ما الذي سيتم فحصه اليوم خلال المراجعة؟',
          tags: <String>['Kontrolle', 'untersucht'],
        ),
        DentistPhrase(
          id: 'dc_xray',
          category: DentistCategory.checkup,
          german: 'Ist heute ein Röntgenbild vorgesehen?',
          arabic: 'هل من المقرر إجراء صورة أشعة اليوم؟',
          tags: <String>['Röntgenbild', 'vorgesehen'],
        ),
        DentistPhrase(
          id: 'dc_findings',
          category: DentistCategory.checkup,
          german: 'Können Sie mir den Befund kurz erklären?',
          arabic: 'هل يمكنكم شرح نتيجة الفحص لي باختصار؟',
          tags: <String>['Befund', 'erklären'],
        ),
        DentistPhrase(
          id: 'dc_followup',
          category: DentistCategory.checkup,
          german: 'Wann sollte ich zur nächsten Kontrolle kommen?',
          arabic: 'متى ينبغي أن آتي للفحص القادم؟',
          tags: <String>['nächste Kontrolle', 'Termin'],
        ),
      ];

  List<DentistPhrase> search(String query) =>
      List<DentistPhrase>.unmodifiable(
        items.where((item) => item.matches(query)),
      );
}
