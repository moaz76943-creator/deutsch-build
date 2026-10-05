import '../domain/exam_models.dart';
import '../domain/exam_repository.dart';

final class LocalExamRepository implements ExamRepository {
  const LocalExamRepository();

  @override
  Future<ExamDefinition> loadExam(CefrExamLevel level) async {
    return switch (level) {
      CefrExamLevel.a1 => _a1,
      CefrExamLevel.a2 => _a2,
    };
  }

  static final ExamDefinition _a1 = ExamDefinition(
    id: 'cefr_a1_original_practice_v1',
    level: CefrExamLevel.a1,
    title: 'CEFR A1 – Standard Practice',
    duration: Duration(minutes: 45),
    questions: <ExamQuestion>[
      ExamQuestion(
        id: 'a1_l_01',
        section: ExamSection.lesen,
        stimulus:
            'Fahrplan: Bus 24 – Zentrum 08:15, Bahnhof 08:28, Universität 08:40.',
        prompt: 'Wann kommt der Bus am Bahnhof an?',
        options: <String>['08:15', '08:28', '08:40'],
        correctOptionIndex: 1,
        points: 10,
      ),
      ExamQuestion(
        id: 'a1_l_02',
        section: ExamSection.lesen,
        stimulus:
            'Supermarkt: Montag bis Samstag 08:00–20:00. Sonntag geschlossen.',
        prompt: 'Wann ist der Supermarkt geschlossen?',
        options: <String>['Montag', 'Samstag', 'Sonntag'],
        correctOptionIndex: 2,
        points: 10,
      ),
      ExamQuestion(
        id: 'a1_l_03',
        section: ExamSection.lesen,
        stimulus:
            'Zimmer frei: 18 m², Küche gemeinsam, 420 Euro im Monat, Nähe Bahnhof.',
        prompt: 'Wie viel kostet das Zimmer pro Monat?',
        options: <String>['18 Euro', '420 Euro', '840 Euro'],
        correctOptionIndex: 1,
        points: 15,
      ),
      ExamQuestion(
        id: 'a1_h_01',
        section: ExamSection.hoeren,
        stimulus:
            'Durchsage: Der Regionalzug nach Bonn fährt heute von Gleis fünf.',
        prompt: 'Von welchem Gleis fährt der Zug?',
        options: <String>['Gleis 3', 'Gleis 5', 'Gleis 8'],
        correctOptionIndex: 1,
        points: 10,
      ),
      ExamQuestion(
        id: 'a1_h_02',
        section: ExamSection.hoeren,
        stimulus:
            'Im Büro: Frau Keller ist heute bis sechzehn Uhr im Büro.',
        prompt: 'Bis wann ist Frau Keller im Büro?',
        options: <String>['14 Uhr', '16 Uhr', '18 Uhr'],
        correctOptionIndex: 1,
        points: 10,
      ),
      ExamQuestion(
        id: 'a1_h_03',
        section: ExamSection.hoeren,
        stimulus:
            'Im Geschäft: Die blaue Jacke kostet heute fünfunddreißig Euro.',
        prompt: 'Was kostet die Jacke?',
        options: <String>['25 Euro', '35 Euro', '45 Euro'],
        correctOptionIndex: 1,
        points: 15,
      ),
      ExamQuestion(
        id: 'a1_s_01',
        section: ExamSection.schreiben,
        prompt:
            'Du kommst zehn Minuten später zur Arbeit. Welche Nachricht ist passend?',
        options: <String>[
          'Guten Morgen, ich komme heute zehn Minuten später.',
          'Zehn später ich heute.',
          'Heute Arbeit später zehn.',
        ],
        correctOptionIndex: 0,
        points: 10,
      ),
      ExamQuestion(
        id: 'a1_s_02',
        section: ExamSection.schreiben,
        prompt:
            'Du möchtest einen Termin am Dienstag. Welche Anfrage ist passend?',
        options: <String>[
          'Haben Sie am Dienstag einen Termin frei?',
          'Dienstag Termin du frei?',
          'Ich Dienstag Termin sein.',
        ],
        correctOptionIndex: 0,
        points: 10,
      ),
      ExamQuestion(
        id: 'a1_s_03',
        section: ExamSection.schreiben,
        prompt:
            'Du fragst nach einem Zimmer. Welche Nachricht ist vollständig und höflich?',
        options: <String>[
          'Guten Tag, ist das Zimmer noch frei? Wie hoch ist die Miete?',
          'Zimmer frei? Preis?',
          'Ich Zimmer nehmen sofort.',
        ],
        correctOptionIndex: 0,
        points: 10,
      ),
    ],
  );

  static final ExamDefinition _a2 = ExamDefinition(
    id: 'cefr_a2_original_practice_v1',
    level: CefrExamLevel.a2,
    title: 'CEFR A2 – Standard Practice',
    duration: Duration(minutes: 55),
    questions: <ExamQuestion>[
      ExamQuestion(
        id: 'a2_l_01',
        section: ExamSection.lesen,
        stimulus:
            'Wegen Bauarbeiten fährt die Linie 7 ab Montag nur bis Marktplatz. Fahrgäste zum Hauptbahnhof steigen dort in die Linie 2 um.',
        prompt: 'Was müssen Fahrgäste zum Hauptbahnhof tun?',
        options: <String>[
          'Am Marktplatz umsteigen.',
          'Bis zur Endstation sitzen bleiben.',
          'Die Linie 7 am Hauptbahnhof nehmen.',
        ],
        correctOptionIndex: 0,
        points: 10,
      ),
      ExamQuestion(
        id: 'a2_l_02',
        section: ExamSection.lesen,
        stimulus:
            'Wohnungsanzeige: Zwei Zimmer, Balkon, 680 Euro kalt. Nebenkosten 140 Euro. Haustiere nach Absprache.',
        prompt: 'Welche Aussage stimmt?',
        options: <String>[
          'Die Nebenkosten sind in 680 Euro enthalten.',
          'Haustiere sind grundsätzlich verboten.',
          'Die Wohnung hat einen Balkon.',
        ],
        correctOptionIndex: 2,
        points: 10,
      ),
      ExamQuestion(
        id: 'a2_l_03',
        section: ExamSection.lesen,
        stimulus:
            'Kursinformation: Der Computerkurs beginnt am 12. Oktober. Unterricht ist dienstags und donnerstags von 18:00 bis 19:30 Uhr.',
        prompt: 'Wie oft findet der Kurs pro Woche statt?',
        options: <String>['Einmal', 'Zweimal', 'Dreimal'],
        correctOptionIndex: 1,
        points: 15,
      ),
      ExamQuestion(
        id: 'a2_h_01',
        section: ExamSection.hoeren,
        stimulus:
            'Telefonnotiz: Herr Baumann kommt heute nicht um zehn, sondern erst um halb zwölf zum Termin.',
        prompt: 'Wann kommt Herr Baumann?',
        options: <String>['10:00', '11:30', '12:30'],
        correctOptionIndex: 1,
        points: 10,
      ),
      ExamQuestion(
        id: 'a2_h_02',
        section: ExamSection.hoeren,
        stimulus:
            'Im Kaufhaus: Die Kasse im Erdgeschoss ist geschlossen. Bitte bezahlen Sie im ersten Stock.',
        prompt: 'Wo kann man bezahlen?',
        options: <String>[
          'Im Erdgeschoss',
          'Im ersten Stock',
          'Im zweiten Stock',
        ],
        correctOptionIndex: 1,
        points: 10,
      ),
      ExamQuestion(
        id: 'a2_h_03',
        section: ExamSection.hoeren,
        stimulus:
            'Teamgespräch: Die Besprechung am Freitag beginnt eine Stunde früher, also um neun Uhr.',
        prompt: 'Wann beginnt die Besprechung?',
        options: <String>['08:00', '09:00', '10:00'],
        correctOptionIndex: 1,
        points: 15,
      ),
      ExamQuestion(
        id: 'a2_s_01',
        section: ExamSection.schreiben,
        prompt:
            'Du kannst morgen nicht zum Kurs kommen. Welche Nachricht erklärt die Situation klar?',
        options: <String>[
          'Guten Tag, ich kann morgen leider nicht teilnehmen. Können Sie mir bitte die Aufgabe schicken?',
          'Morgen nein Kurs, Aufgabe schicken.',
          'Ich nicht morgen, was Aufgabe?',
        ],
        correctOptionIndex: 0,
        points: 10,
      ),
      ExamQuestion(
        id: 'a2_s_02',
        section: ExamSection.schreiben,
        prompt:
            'Du möchtest einen Besichtigungstermin für eine Wohnung vereinbaren. Welche Formulierung passt?',
        options: <String>[
          'Ich interessiere mich für die Wohnung. Wäre ein Termin am Mittwochabend möglich?',
          'Wohnung Mittwoch ich kommen?',
          'Mittwoch Wohnung Termin machen du.',
        ],
        correctOptionIndex: 0,
        points: 10,
      ),
      ExamQuestion(
        id: 'a2_s_03',
        section: ExamSection.schreiben,
        prompt:
            'Eine Lieferung ist noch nicht angekommen. Welche Nachricht ist sachlich und höflich?',
        options: <String>[
          'Guten Tag, meine Lieferung ist noch nicht angekommen. Können Sie bitte den Status prüfen?',
          'Wo Paket? Sofort sagen.',
          'Lieferung falsch, ich warten.',
        ],
        correctOptionIndex: 0,
        points: 10,
      ),
    ],
  );
}
