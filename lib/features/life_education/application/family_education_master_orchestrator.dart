import '../data/education_catalog.dart';
import '../domain/education_models.dart';

final class DaycareSubAgent {
  DaycareSubAgent(Iterable<EducationEntry> entries)
      : entries = List<EducationEntry>.unmodifiable(
          entries.where((entry) => entry.area == EducationArea.daycare),
        );

  final List<EducationEntry> entries;

  List<EducationEntry> byTopic(EducationTopic topic) =>
      List<EducationEntry>.unmodifiable(
        entries.where((entry) => entry.topic == topic),
      );

  List<EducationEntry> search({
    EducationLevel? level,
    String query = '',
  }) =>
      _filterEntries(
        entries,
        level: level,
        query: query,
      );
}

final class SchoolCommunicationSubAgent {
  SchoolCommunicationSubAgent(Iterable<EducationEntry> entries)
      : entries = List<EducationEntry>.unmodifiable(
          entries.where((entry) => entry.area == EducationArea.school),
        );

  final List<EducationEntry> entries;

  List<EducationEntry> byTopic(EducationTopic topic) =>
      List<EducationEntry>.unmodifiable(
        entries.where((entry) => entry.topic == topic),
      );

  List<EducationEntry> search({
    EducationLevel? level,
    String query = '',
  }) =>
      _filterEntries(
        entries,
        level: level,
        query: query,
      );
}

final class FamilyEducationMasterOrchestrator {
  FamilyEducationMasterOrchestrator._({
    required this.entries,
    required this.daycare,
    required this.school,
    required Map<EducationArea, EmergencyAbsenceMessage> absenceByArea,
  }) : _absenceByArea =
            Map<EducationArea, EmergencyAbsenceMessage>.unmodifiable(
          absenceByArea,
        );

  factory FamilyEducationMasterOrchestrator.standard() {
    final entries = List<EducationEntry>.unmodifiable(EducationCatalog.entries);
    _validate(entries);

    return FamilyEducationMasterOrchestrator._(
      entries: entries,
      daycare: DaycareSubAgent(entries),
      school: SchoolCommunicationSubAgent(entries),
      absenceByArea: const <EducationArea, EmergencyAbsenceMessage>{
        EducationArea.daycare: EducationCatalog.daycareAbsence,
        EducationArea.school: EducationCatalog.schoolAbsence,
      },
    );
  }

  final List<EducationEntry> entries;
  final DaycareSubAgent daycare;
  final SchoolCommunicationSubAgent school;
  final Map<EducationArea, EmergencyAbsenceMessage> _absenceByArea;

  List<EducationEntry> filter({
    EducationLevel? level,
    EducationArea? area,
    String query = '',
  }) {
    final scoped = area == null
        ? entries
        : entries.where((entry) => entry.area == area);

    return _filterEntries(
      scoped,
      level: level,
      query: query,
    );
  }

  EmergencyAbsenceMessage emergencyAbsence(EducationArea area) {
    final message = _absenceByArea[area];
    if (message == null) {
      throw StateError('Missing emergency absence message');
    }
    return message;
  }

  static void _validate(List<EducationEntry> entries) {
    if (entries.isEmpty) {
      throw StateError('Family education catalog must not be empty');
    }

    final ids = <String>{};
    for (final entry in entries) {
      if (entry.id.trim().isEmpty || !ids.add(entry.id)) {
        throw StateError('Education entry ids must be non-empty and unique');
      }
      if (entry.germanText.trim().isEmpty || entry.arabicText.trim().isEmpty) {
        throw StateError('Every education entry needs German and Arabic text');
      }
    }

    for (final level in EducationLevel.values) {
      if (!entries.any((entry) => entry.level == level)) {
        throw StateError('Every CEFR filter must contain at least one entry');
      }
    }

    const requiredDaycareTopics = <EducationTopic>{
      EducationTopic.dropOffPickup,
      EducationTopic.allergy,
      EducationTopic.dailyRoutine,
      EducationTopic.careTimes,
    };
    const requiredSchoolTopics = <EducationTopic>{
      EducationTopic.sickLeave,
      EducationTopic.parentTeacherConference,
      EducationTopic.homework,
    };

    final daycareTopics = entries
        .where((entry) => entry.area == EducationArea.daycare)
        .map((entry) => entry.topic)
        .toSet();
    final schoolTopics = entries
        .where((entry) => entry.area == EducationArea.school)
        .map((entry) => entry.topic)
        .toSet();

    if (!daycareTopics.containsAll(requiredDaycareTopics)) {
      throw StateError('Daycare sub-agent is missing a required topic');
    }
    if (!schoolTopics.containsAll(requiredSchoolTopics)) {
      throw StateError('School sub-agent is missing a required topic');
    }
  }
}

List<EducationEntry> _filterEntries(
  Iterable<EducationEntry> source, {
  EducationLevel? level,
  String query = '',
}) {
  final normalizedQuery = _normalize(query);
  final tokens = normalizedQuery.isEmpty
      ? const <String>[]
      : normalizedQuery.split(' ').where((token) => token.isNotEmpty).toList();

  final results = source.where((entry) {
    if (level != null && entry.level != level) return false;
    if (tokens.isEmpty) return true;

    final haystack = _normalize(entry.searchableText);
    return tokens.every(haystack.contains);
  }).toList(growable: false);

  return List<EducationEntry>.unmodifiable(results);
}

String _normalize(String value) {
  return value
      .toLowerCase()
      .trim()
      .replaceAll('ä', 'ae')
      .replaceAll('ö', 'oe')
      .replaceAll('ü', 'ue')
      .replaceAll('ß', 'ss')
      .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
