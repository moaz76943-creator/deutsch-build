import '../domain/placement_models.dart';
import '../domain/placement_repositories.dart';

final class LocalPlacementRepository implements PlacementRepository {
  LocalPlacementRepository();

  static final List<PlacementQuestion> _questions = <PlacementQuestion>[
    PlacementQuestion(
      id: 'a1-article-fluss',
      promptArabic: 'ما أداة التعريف الصحيحة لكلمة Fluss؟',
      level: PlacementLevel.a1,
      pattern: PlacementQuestionPattern.grammar,
      options: const <PlacementOption>[
        PlacementOption(id: 'der', text: 'der Fluss'),
        PlacementOption(id: 'die', text: 'die Fluss'),
        PlacementOption(id: 'das', text: 'das Fluss'),
      ],
      correctOptionId: 'der',
      skillTag: 'grammar',
      reviewItemId: 'w0745',
    ),
    PlacementQuestion(
      id: 'a1-meaning-baum',
      promptArabic: 'أي كلمة ألمانية تعني «شجرة»؟',
      level: PlacementLevel.a1,
      pattern: PlacementQuestionPattern.translation,
      options: const <PlacementOption>[
        PlacementOption(id: 'baum', text: 'Baum'),
        PlacementOption(id: 'wald', text: 'Wald'),
        PlacementOption(id: 'blume', text: 'Blume'),
      ],
      correctOptionId: 'baum',
      skillTag: 'vocabulary',
      reviewItemId: 'w0747',
    ),
    PlacementQuestion(
      id: 'a1-meaning-blume',
      promptArabic: 'اختر المعنى الصحيح لكلمة Blume.',
      level: PlacementLevel.a1,
      pattern: PlacementQuestionPattern.multipleChoice,
      options: const <PlacementOption>[
        PlacementOption(id: 'flower', text: 'زهرة'),
        PlacementOption(id: 'grass', text: 'عشب'),
        PlacementOption(id: 'river', text: 'نهر'),
      ],
      correctOptionId: 'flower',
      skillTag: 'vocabulary',
      reviewItemId: 'w0748',
    ),
    PlacementQuestion(
      id: 'a1-listening-spazieren',
      promptArabic: 'استمع واختر المعنى الأقرب.',
      level: PlacementLevel.a1,
      pattern: PlacementQuestionPattern.listening,
      options: const <PlacementOption>[
        PlacementOption(id: 'walk', text: 'يتمشّى'),
        PlacementOption(id: 'draw', text: 'يرسم'),
        PlacementOption(id: 'change', text: 'يغيّر'),
      ],
      correctOptionId: 'walk',
      skillTag: 'listening',
      audioText: 'Wir spazieren im Park.',
      reviewItemId: 'w0590',
    ),
    PlacementQuestion(
      id: 'a2-prefix-abfahren',
      promptArabic: 'أكمل الجملة: Der Zug fährt um neun ___.',
      level: PlacementLevel.a2,
      pattern: PlacementQuestionPattern.grammar,
      options: const <PlacementOption>[
        PlacementOption(id: 'ab', text: 'ab'),
        PlacementOption(id: 'an', text: 'an'),
        PlacementOption(id: 'auf', text: 'auf'),
      ],
      correctOptionId: 'ab',
      skillTag: 'grammar',
      reviewItemId: 'w0589',
    ),
    PlacementQuestion(
      id: 'a2-meaning-wechseln',
      promptArabic: 'ما المعنى الأقرب للفعل wechseln؟',
      level: PlacementLevel.a2,
      pattern: PlacementQuestionPattern.translation,
      options: const <PlacementOption>[
        PlacementOption(id: 'change', text: 'يغيّر / يبدّل'),
        PlacementOption(id: 'remember', text: 'يتذكّر'),
        PlacementOption(id: 'need', text: 'يحتاج'),
      ],
      correctOptionId: 'change',
      skillTag: 'vocabulary',
      reviewItemId: 'w0592',
    ),
    PlacementQuestion(
      id: 'a2-listening-erinnern',
      promptArabic: 'استمع واختر المعنى الصحيح للجملة.',
      level: PlacementLevel.a2,
      pattern: PlacementQuestionPattern.listening,
      options: const <PlacementOption>[
        PlacementOption(id: 'remember', text: 'أتذكّر الموعد.'),
        PlacementOption(id: 'move', text: 'أغيّر الموعد.'),
        PlacementOption(id: 'cancel', text: 'ألغي الموعد.'),
      ],
      correctOptionId: 'remember',
      skillTag: 'listening',
      audioText: 'Ich erinnere mich an den Termin.',
      reviewItemId: 'w0588',
    ),
    PlacementQuestion(
      id: 'a2-sentence-schneiden',
      promptArabic: 'ما معنى الجملة: Ich schneide das Brot.؟',
      level: PlacementLevel.a2,
      pattern: PlacementQuestionPattern.translation,
      options: const <PlacementOption>[
        PlacementOption(id: 'cut', text: 'أنا أقطع الخبز.'),
        PlacementOption(id: 'bake', text: 'أنا أخبز الخبز.'),
        PlacementOption(id: 'serve', text: 'أنا أقدّم الخبز.'),
      ],
      correctOptionId: 'cut',
      skillTag: 'translation',
      reviewItemId: 'w0407',
    ),
    PlacementQuestion(
      id: 'b1-context-benoetigen',
      promptArabic: 'اختر الفعل الأنسب: Wir ___ mehr Zeit für die Aufgabe.',
      level: PlacementLevel.b1,
      pattern: PlacementQuestionPattern.grammar,
      options: const <PlacementOption>[
        PlacementOption(id: 'need', text: 'benötigen'),
        PlacementOption(id: 'draw', text: 'zeichnen'),
        PlacementOption(id: 'walk', text: 'spazieren'),
      ],
      correctOptionId: 'need',
      skillTag: 'grammar',
      reviewItemId: 'w0593',
    ),
    PlacementQuestion(
      id: 'b1-context-organisieren',
      promptArabic: 'أي فعل يناسب معنى «ينظّم» في سياق التخطيط لاجتماع؟',
      level: PlacementLevel.b1,
      pattern: PlacementQuestionPattern.translation,
      options: const <PlacementOption>[
        PlacementOption(id: 'organize', text: 'organisieren'),
        PlacementOption(id: 'serve', text: 'servieren'),
        PlacementOption(id: 'fry', text: 'braten'),
      ],
      correctOptionId: 'organize',
      skillTag: 'vocabulary',
      reviewItemId: 'w0594',
    ),
    PlacementQuestion(
      id: 'b1-contrast-sicher',
      promptArabic: 'اختر الكلمة الأقرب لعكس gefährlich.',
      level: PlacementLevel.b1,
      pattern: PlacementQuestionPattern.multipleChoice,
      options: const <PlacementOption>[
        PlacementOption(id: 'safe', text: 'sicher'),
        PlacementOption(id: 'boring', text: 'langweilig'),
        PlacementOption(id: 'practical', text: 'praktisch'),
      ],
      correctOptionId: 'safe',
      skillTag: 'vocabulary',
      reviewItemId: 'w0485',
    ),
    PlacementQuestion(
      id: 'b1-listening-interesting',
      promptArabic: 'استمع ثم اختر الفكرة الأقرب.',
      level: PlacementLevel.b1,
      pattern: PlacementQuestionPattern.listening,
      options: const <PlacementOption>[
        PlacementOption(id: 'interesting', text: 'الموضوع مثير للاهتمام.'),
        PlacementOption(id: 'boring', text: 'الموضوع ممل.'),
        PlacementOption(id: 'dangerous', text: 'الموضوع خطير.'),
      ],
      correctOptionId: 'interesting',
      skillTag: 'listening',
      audioText: 'Das Thema ist wirklich interessant.',
      reviewItemId: 'w0482',
    ),

    PlacementQuestion(
      id: 'b2-konjunktiv-past',
      promptArabic: 'أكمل: Wenn ich mehr Zeit gehabt hätte, ___ ich den Kurs abgeschlossen.',
      level: PlacementLevel.b2,
      pattern: PlacementQuestionPattern.grammar,
      options: const <PlacementOption>[
        PlacementOption(id: 'haette', text: 'hätte'),
        PlacementOption(id: 'habe', text: 'habe'),
        PlacementOption(id: 'werde', text: 'werde'),
      ],
      correctOptionId: 'haette',
      skillTag: 'grammar',
    ),
    PlacementQuestion(
      id: 'b2-passive-deadline',
      promptArabic: 'ما المعنى الأدق: Die Unterlagen müssen bis Freitag eingereicht worden sein.؟',
      level: PlacementLevel.b2,
      pattern: PlacementQuestionPattern.translation,
      options: const <PlacementOption>[
        PlacementOption(
          id: 'submitted',
          text: 'يجب أن تكون المستندات قد قُدّمت بحلول الجمعة.',
        ),
        PlacementOption(
          id: 'submit-later',
          text: 'يمكن تقديم المستندات بعد الجمعة.',
        ),
        PlacementOption(
          id: 'received',
          text: 'يجب استلام المستندات يوم الجمعة فقط.',
        ),
      ],
      correctOptionId: 'submitted',
      skillTag: 'translation',
    ),
    PlacementQuestion(
      id: 'b2-je-desto',
      promptArabic: 'اختر البنية الصحيحة: ___ länger man übt, ___ sicherer spricht man.',
      level: PlacementLevel.b2,
      pattern: PlacementQuestionPattern.grammar,
      options: const <PlacementOption>[
        PlacementOption(id: 'je-desto', text: 'Je … desto'),
        PlacementOption(id: 'weil-dann', text: 'Weil … dann'),
        PlacementOption(id: 'obwohl-deshalb', text: 'Obwohl … deshalb'),
      ],
      correctOptionId: 'je-desto',
      skillTag: 'grammar',
    ),
    PlacementQuestion(
      id: 'b2-listening-deadline',
      promptArabic: 'استمع ثم اختر الفكرة الأقرب.',
      level: PlacementLevel.b2,
      pattern: PlacementQuestionPattern.listening,
      options: const <PlacementOption>[
        PlacementOption(
          id: 'on-time',
          text: 'نجح الفريق في تسليم التقرير في الموعد رغم ضيق المهلة.',
        ),
        PlacementOption(
          id: 'late',
          text: 'تأخر الفريق عن الموعد بسبب قصر المهلة.',
        ),
        PlacementOption(
          id: 'cancelled',
          text: 'ألغى الفريق إعداد التقرير.',
        ),
      ],
      correctOptionId: 'on-time',
      skillTag: 'listening',
      audioText:
          'Obwohl die Frist knapp bemessen war, gelang es dem Team, den Bericht fristgerecht einzureichen.',
    ),
  ];

  @override
  Future<int> availableQuestionCount() async => _questions.length;

  @override
  Future<PlacementQuestion?> nextQuestion({
    required PlacementLevel level,
    required Set<String> excludeIds,
  }) async {
    for (final question in _questions) {
      if (question.level == level && !excludeIds.contains(question.id)) {
        return question;
      }
    }

    for (var distance = 1; distance <= 3; distance += 1) {
      final lower = level.rank - distance;
      final higher = level.rank + distance;
      for (final candidateRank in <int>[lower, higher]) {
        if (candidateRank < 0 || candidateRank > 3) continue;
        final candidateLevel = PlacementLevel.fromRank(candidateRank);
        for (final question in _questions) {
          if (question.level == candidateLevel &&
              !excludeIds.contains(question.id)) {
            return question;
          }
        }
      }
    }
    return null;
  }
}
