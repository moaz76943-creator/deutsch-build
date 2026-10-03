import 'package:flutter/foundation.dart';

import '../data/local_mobility_repository.dart';
import '../domain/mobility_models.dart';

class LongDistanceTrainSubAgent {
  const LongDistanceTrainSubAgent(this.repository);

  final LocalMobilityRepository repository;

  List<MobilityLesson> platformChanges({MobilityLevel? level}) =>
      _topic(MobilityTopic.platformChange, level);

  List<MobilityLesson> delays({MobilityLevel? level}) =>
      _topic(MobilityTopic.delay, level);

  List<MobilityLesson> seatReservations({MobilityLevel? level}) =>
      _topic(MobilityTopic.seatReservation, level);

  List<MobilityLesson> _topic(
    MobilityTopic topic,
    MobilityLevel? level,
  ) =>
      repository
          .byTopic(topic)
          .where(
            (item) =>
                item.mode == MobilityMode.longDistance &&
                (level == null || item.level == level),
          )
          .toList(growable: false);
}

class LocalTransitSubAgent {
  const LocalTransitSubAgent(this.repository);

  final LocalMobilityRepository repository;

  List<MobilityLesson> localTickets({MobilityLevel? level}) =>
      _topic(MobilityTopic.localTicket, level);

  List<MobilityLesson> deutschlandticket({MobilityLevel? level}) =>
      _topic(MobilityTopic.deutschlandticket, level);

  List<MobilityLesson> busConnections({MobilityLevel? level}) =>
      _topic(MobilityTopic.busConnection, level);

  List<MobilityLesson> _topic(
    MobilityTopic topic,
    MobilityLevel? level,
  ) =>
      repository
          .byTopic(topic)
          .where(
            (item) =>
                item.mode == MobilityMode.localTransit &&
                (level == null || item.level == level),
          )
          .toList(growable: false);
}

class MobilityMasterOrchestrator extends ChangeNotifier {
  MobilityMasterOrchestrator(this.repository)
      : longDistance = LongDistanceTrainSubAgent(repository),
        localTransit = LocalTransitSubAgent(repository);

  final LocalMobilityRepository repository;
  final LongDistanceTrainSubAgent longDistance;
  final LocalTransitSubAgent localTransit;

  MobilityLevel? _selectedLevel;
  String _query = '';
  bool _isPanicBarOpen = false;

  MobilityLevel? get selectedLevel => _selectedLevel;
  String get query => _query;
  bool get isPanicBarOpen => _isPanicBarOpen;

  List<MobilityLesson> get visibleItems =>
      repository.search(_query, level: _selectedLevel);

  List<PlatformPanicStep> get platformPanicSteps => const <PlatformPanicStep>[
        PlatformPanicStep(
          titleDe: '1. Anzeigetafel prüfen',
          instructionAr:
              'طابق رقم القطار والوجهة أولًا، ثم اقرأ رقم الرصيف الجديد.',
        ),
        PlatformPanicStep(
          titleDe: '2. Gleiswechsel bestätigen',
          instructionAr:
              'تحقق من إعلان المحطة أو التطبيق الرسمي قبل مغادرة الرصيف الحالي.',
        ),
        PlatformPanicStep(
          titleDe: '3. Zum neuen Gleis gehen',
          instructionAr:
              'اتبع لوحات Gleis واستخدم المصعد أو الدرج المناسب دون استعجال خطر.',
        ),
        PlatformPanicStep(
          titleDe: '4. Bei Unklarheit nachfragen',
          instructionAr:
              'قل: Entschuldigung, von welchem Gleis fährt mein Zug ab?',
        ),
      ];

  void setLevel(MobilityLevel? level) {
    if (_selectedLevel == level) return;
    _selectedLevel = level;
    notifyListeners();
  }

  void search(String value) {
    final normalized = value.trim();
    if (_query == normalized) return;
    _query = normalized;
    notifyListeners();
  }

  void clearSearch() => search('');

  void togglePanicBar() {
    _isPanicBarOpen = !_isPanicBarOpen;
    notifyListeners();
  }
}
