import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../../../services/database_service.dart';

/// Only topic metadata lives here; lexical content and translations stay in
/// the existing immutable SQLite database. An entry can belong to many topics
/// without duplicating its identity or the learner's SRS progress.
class LocalTopicSection {
  const LocalTopicSection(this.id, this.title);
  final String id;
  final String title;
}

/// Curated topic anchors, NOT a redistributable dictionary or language pack.
///
/// These common German headwords are hand-selected from the existing bundled
/// TSV. They are lookup keys, not copies of translations, examples or dataset
/// bytes. The source/rights status of those SQLite records does not change.
class LocalTopicCatalog {
  static const List<LocalTopicSection> sections = <LocalTopicSection>[
    LocalTopicSection('HOME_KITCHEN', 'المطبخ والطعام 🍳'),
    LocalTopicSection('FAMILY', 'العائلة والأسرة 👨‍👩‍👧'),
    LocalTopicSection('HOME_LIVING', 'المنزل والحياة اليومية 🏠'),
    LocalTopicSection('SCHOOL', 'المدرسة والدراسة 📚'),
    LocalTopicSection('TRANSPORT', 'السفر والمواصلات 🚆'),
    LocalTopicSection('HEALTH', 'الصحة والعناية 🩺'),
    LocalTopicSection('WORK', 'العمل والتسوق 💼'),
    LocalTopicSection('CLOTHING', 'الملابس 👕'),
    LocalTopicSection('TIME', 'الوقت والأيام 🕒'),
  ];

  // Exact-case matching deliberately distinguishes German noun 'Essen'
  // from the verb 'essen'. Entries absent from a future licensed database
  // simply do not appear; no synthesized translations or fallback content.
  static const Map<String, List<String>> _germanHeads =
      <String, List<String>>{
    'HOME_KITCHEN': <String>[
      'Brot', 'Ei', 'Essen', 'Fisch', 'Fleisch', 'Kaffee', 'Käse',
      'Milch', 'Wasser', 'Apfel', 'Tasse', 'kochen', 'trinken',
      'schneiden', 'Zucker', 'Salz',
    ],
    'FAMILY': <String>[
      'Familie', 'Mutter', 'Vater', 'Bruder', 'Schwester', 'Kind',
      'Sohn', 'Tochter', 'Freund', 'Frau', 'Mann', 'heiraten', 'lieben',
    ],
    'HOME_LIVING': <String>[
      'Haus', 'Zimmer', 'Fenster', 'Tür', 'Bett', 'Tisch', 'Stuhl',
      'Lampe', 'Schrank', 'Wohnung', 'Garten', 'wohnen',
    ],
    'SCHOOL': <String>[
      'Schule', 'Buch', 'Lehrer', 'Schüler', 'lernen', 'lesen',
      'schreiben', 'Universität', 'Papier', 'Frage', 'Antwort',
      'erklären', 'verstehen',
    ],
    'TRANSPORT': <String>[
      'Bus', 'Bahnhof', 'Auto', 'Zug', 'Straße', 'fahren',
      'reisen', 'gehen',
    ],
    'HEALTH': <String>['Arzt', 'Hand', 'Kopf', 'helfen'],
    'WORK': <String>['Arbeit', 'Geld', 'Geschäft', 'kaufen', 'arbeiten'],
    'CLOTHING': <String>['Hemd', 'Jacke', 'anziehen', 'kaufen'],
    'TIME': <String>[
      'Zeit', 'Tag', 'Woche', 'Monat', 'Jahr', 'gestern',
      'heute', 'Morgen',
    ],
  };

  static bool supportsBundledTopics(String languageCode) =>
      languageCode == 'de';

  /// Read-only and bounded. Uses the already-verified, locally bundled content
  /// database, without downloading anything or writing to the learner DB.
  static Future<List<Map<String, dynamic>>> loadSection({
    required String sectionId,
    required String cefr,
    required String languageCode,
  }) async {
    if (!supportsBundledTopics(languageCode)) {
      return <Map<String, dynamic>>[];
    }
    return DatabaseService.instance.withContentDb(
      languageCode,
      (db) => querySectionFromDb(
        db,
        sectionId: sectionId,
        cefr: cefr,
        languageCode: languageCode,
      ),
    );
  }

  @visibleForTesting
  static Future<List<Map<String, dynamic>>> querySectionFromDb(
    Database db, {
    required String sectionId,
    required String cefr,
    required String languageCode,
  }) async {
    final headwords = _germanHeads[sectionId];
    if (languageCode != 'de' ||
        headwords == null ||
        headwords.isEmpty ||
        !const <String>{'A1', 'A2', 'B1', 'B2'}
            .contains(cefr.toUpperCase())) {
      return <Map<String, dynamic>>[];
    }
    final markers = List<String>.filled(headwords.length, '?').join(',');
    final rows = await db.rawQuery('''
      SELECT l.id AS lexeme_id,
        COALESCE((
          SELECT s.concept_id FROM senses AS s
          WHERE s.lexeme_id = l.id
          ORDER BY s.concept_id LIMIT 1
        ), l.id) AS concept_id,
        l.surface AS word, l.part_of_speech, l.cefr_level, l.fields_json
      FROM lexicon AS l
      WHERE l.language_code = ? AND l.cefr_level = ?
        AND l.surface COLLATE BINARY IN ($markers)
      ORDER BY l.sort_key, l.id
      LIMIT 50
    ''', <Object?>[languageCode, cefr.toUpperCase(), ...headwords]);

    return rows.map((row) {
      Map<String, dynamic> fields = <String, dynamic>{};
      final encoded = row['fields_json'];
      if (encoded is String && encoded.isNotEmpty) {
        try {
          final parsed = jsonDecode(encoded);
          if (parsed is Map) {
            fields = parsed.map(
              (key, value) => MapEntry(key.toString(), value),
            );
          }
        } on FormatException {
          // Optional malformed metadata must not invent a translation.
        }
      }
      final arabic = fields['translation_ar'] ?? fields['translation'];
      return <String, dynamic>{
        'concept_id': row['concept_id'],
        'lexeme_id': row['lexeme_id'],
        'language_code': languageCode,
        'word': row['word'],
        'display_text': row['word'],
        'part_of_speech': row['part_of_speech'],
        'cefr_level': row['cefr_level'],
        'translation_ar': arabic is String ? arabic : null,
        'article': fields['article'],
      };
    }).toList(growable: false);
  }
}
