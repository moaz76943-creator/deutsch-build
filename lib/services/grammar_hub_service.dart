import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class GrammarTopic {
  final String id;
  final String level;
  final String titleDe;
  final String titleAr;
  final String explanationMarkdown;
  final String? formulaPattern;
  final int orderIndex;
  final bool isMastered;

  GrammarTopic({
    required this.id,
    required this.level,
    required this.titleDe,
    required this.titleAr,
    required this.explanationMarkdown,
    this.formulaPattern,
    required this.orderIndex,
    this.isMastered = false,
  });

  factory GrammarTopic.fromMap(Map<String, dynamic> map) {
    return GrammarTopic(
      id: map['id'] as String,
      level: map['level'] as String,
      titleDe: map['title_de'] as String,
      titleAr: map['title_ar'] as String,
      explanationMarkdown: map['explanation_markdown'] as String,
      formulaPattern: map['formula_pattern'] as String?,
      orderIndex: map['order_index'] as int,
      isMastered: (map['is_mastered'] as int? ?? 0) == 1,
    );
  }
}

class GrammarQuiz {
  final int? id;
  final String topicId;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  GrammarQuiz({
    this.id,
    required this.topicId,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  factory GrammarQuiz.fromMap(Map<String, dynamic> map) {
    return GrammarQuiz(
      id: map['id'] as int?,
      topicId: map['topic_id'] as String,
      question: map['question'] as String,
      options: List<String>.from(json.decode(map['options_json'] as String)),
      correctIndex: map['correct_index'] as int,
      explanation: map['explanation'] as String,
    );
  }
}

class GrammarHubService {
  static const String _dbName = 'grammar_hub.db';
  Database? _db;
  final DatabaseFactory? _dbFactory;
  final String? _inMemoryPath;

  GrammarHubService({DatabaseFactory? factory, String? path})
    : _dbFactory = factory,
      _inMemoryPath = path;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    String path;
    if (_inMemoryPath != null) {
      path = _inMemoryPath;
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, _dbName);
    }

    final factory = _dbFactory;
    if (factory != null) {
      return await factory.openDatabase(
        path,
        options: OpenDatabaseOptions(version: 1, onCreate: _createDB),
      );
    }

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE grammar_topics (
        id TEXT PRIMARY KEY,
        level TEXT NOT NULL,
        title_de TEXT NOT NULL,
        title_ar TEXT NOT NULL,
        explanation_markdown TEXT NOT NULL,
        formula_pattern TEXT,
        order_index INTEGER NOT NULL,
        is_mastered INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE grammar_quizzes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        topic_id TEXT NOT NULL,
        question TEXT NOT NULL,
        options_json TEXT NOT NULL,
        correct_index INTEGER NOT NULL,
        explanation TEXT NOT NULL,
        FOREIGN KEY (topic_id) REFERENCES grammar_topics (id) ON DELETE CASCADE
      )
    ''');

    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    // Seed A1
    await db.insert('grammar_topics', {
      'id': 'a1_nominativ',
      'level': 'A1',
      'title_de': 'Nominativ',
      'title_ar': 'حالة الرفع',
      'explanation_markdown': 'Der Nominativ ist die Grundform des Nomens.',
      'formula_pattern': 'Wer oder Was?',
      'order_index': 1,
      'is_mastered': 0,
    });

    // Seed A1 Quizzes
    await db.insert('grammar_quizzes', {
      'topic_id': 'a1_nominativ',
      'question': 'Welcher Artikel steht im Nominativ für maskulin?',
      'options_json': json.encode(['der', 'den', 'dem', 'des']),
      'correct_index': 0,
      'explanation': '"der" ist der maskuline Artikel im Nominativ.',
    });
    await db.insert('grammar_quizzes', {
      'topic_id': 'a1_nominativ',
      'question': 'Welcher Artikel steht im Nominativ für feminin?',
      'options_json': json.encode(['der', 'die', 'das', 'den']),
      'correct_index': 1,
      'explanation': '"die" ist der feminine Artikel im Nominativ.',
    });
    await db.insert('grammar_quizzes', {
      'topic_id': 'a1_nominativ',
      'question': 'Welcher Artikel steht im Nominativ für neutral?',
      'options_json': json.encode(['das', 'der', 'dem', 'den']),
      'correct_index': 0,
      'explanation': '"das" ist der neutrale Artikel im Nominativ.',
    });

    // Seed A2
    await db.insert('grammar_topics', {
      'id': 'a2_perfekt',
      'level': 'A2',
      'title_de': 'Perfekt',
      'title_ar': 'الماضي التام',
      'explanation_markdown':
          'Das Perfekt wird mit haben/sein + Partizip II gebildet.',
      'formula_pattern': 'haben/sein + ... + Partizip II',
      'order_index': 1,
      'is_mastered': 0,
    });

    // Seed A2 Quizzes
    await db.insert('grammar_quizzes', {
      'topic_id': 'a2_perfekt',
      'question': 'Wie lautet das Partizip II von "gehen"?',
      'options_json': json.encode(['gegangen', 'geht', 'geging', 'gegang']),
      'correct_index': 0,
      'explanation': 'Das Partizip II von "gehen" ist "gegangen".',
    });
    await db.insert('grammar_quizzes', {
      'topic_id': 'a2_perfekt',
      'question': 'Welches Hilfsverb wird für "gehen" im Perfekt verwendet?',
      'options_json': json.encode(['haben', 'werden', 'sein', 'wollen']),
      'correct_index': 2,
      'explanation':
          'Verben der Bewegung wie "gehen" bilden das Perfekt mit "sein".',
    });
    await db.insert('grammar_quizzes', {
      'topic_id': 'a2_perfekt',
      'question': 'Wie lautet das Partizip II von "machen"?',
      'options_json': json.encode(['macht', 'machte', 'gemacht', 'machen']),
      'correct_index': 2,
      'explanation': 'Das Partizip II von "machen" ist "gemacht".',
    });

    // Seed B1
    await db.insert('grammar_topics', {
      'id': 'b1_passiv',
      'level': 'B1',
      'title_de': 'Passiv',
      'title_ar': 'المبني للمجهول',
      'explanation_markdown':
          'Das Passiv betont die Handlung, nicht den Täter.',
      'formula_pattern': 'werden + Partizip II',
      'order_index': 1,
      'is_mastered': 0,
    });

    // Seed B1 Quizzes
    await db.insert('grammar_quizzes', {
      'topic_id': 'b1_passiv',
      'question': 'Welches Hilfsverb bildet das Vorgangspassiv?',
      'options_json': json.encode(['haben', 'werden', 'sein', 'können']),
      'correct_index': 1,
      'explanation':
          'Das Vorgangspassiv wird mit "werden" + Partizip II gebildet.',
    });
    await db.insert('grammar_quizzes', {
      'topic_id': 'b1_passiv',
      'question':
          'Wie lautet das Partizip II im Passiv-Satz "Das Haus wird ___"?',
      'options_json': json.encode(['gebaut', 'bauen', 'baut', 'baute']),
      'correct_index': 0,
      'explanation': 'Das Partizip II von "bauen" ist "gebaut".',
    });
    await db.insert('grammar_quizzes', {
      'topic_id': 'b1_passiv',
      'question': 'Was ist das Zustandspassiv von "Die Tür wird geschlossen"?',
      'options_json': json.encode([
        'Die Tür wurde geschlossen',
        'Die Tür ist geschlossen',
        'Die Tür schließt',
        'Die Tür hatte geschlossen',
      ]),
      'correct_index': 1,
      'explanation':
          'Das Zustandspassiv wird mit "sein" + Partizip II gebildet.',
    });

    // Seed B2
    await db.insert('grammar_topics', {
      'id': 'b2_konjunktiv2',
      'level': 'B2',
      'title_de': 'Konjunktiv II',
      'title_ar': 'صيغة التمني',
      'explanation_markdown': 'Verwendet für irreale Wünsche und Bedingungen.',
      'formula_pattern': 'würde + Infinitiv',
      'order_index': 1,
      'is_mastered': 0,
    });

    // Seed B2 Quizzes
    await db.insert('grammar_quizzes', {
      'topic_id': 'b2_konjunktiv2',
      'question': 'Wie lautet der Konjunktiv II von "haben" (ich)?',
      'options_json': json.encode(['habe', 'hätte', 'hatte', 'hätte gehabt']),
      'correct_index': 1,
      'explanation': 'Die Konjunktiv II Form von "haben" ist "hätte".',
    });
    await db.insert('grammar_quizzes', {
      'topic_id': 'b2_konjunktiv2',
      'question': 'Wie lautet der Konjunktiv II von "sein" (ich)?',
      'options_json': json.encode(['wäre', 'war', 'bin', 'wurde']),
      'correct_index': 0,
      'explanation': 'Die Konjunktiv II Form von "sein" ist "wäre".',
    });
    await db.insert('grammar_quizzes', {
      'topic_id': 'b2_konjunktiv2',
      'question': 'Welche Form wird oft als Ersatzform für den Konjunktiv II verwendet?',
      'options_json': json.encode([
        'wäre + Partizip II',
        'würde + Infinitiv',
        'hätte + Infinitiv',
        'wurde + Partizip II',
      ]),
      'correct_index': 1,
      'explanation': 'Die "würde + Infinitiv" Form wird als Ersatzform für schwache Verben und oft im Gesprochenen verwendet.',
    });

    // Seed C1
    await db.insert('grammar_topics', {
      'id': 'c1_partizipialattribute',
      'level': 'C1',
      'title_de': 'Partizipialattribute',
      'title_ar': 'صفات اسم الفاعل والمفعول',
      'explanation_markdown': 'Erweiterte Attribute mit Partizip I oder II.',
      'formula_pattern': 'Artikel + Erweiterung + Partizip + Nomen',
      'order_index': 1,
      'is_mastered': 0,
    });

    // Seed C1 Quizzes
    await db.insert('grammar_quizzes', {
      'topic_id': 'c1_partizipialattribute',
      'question': 'Welches Partizip drückt Gleichzeitigkeit/Aktiv aus?',
      'options_json': json.encode([
        'Partizip II',
        'Partizip I',
        'Infinitiv',
        'Konjunktiv',
      ]),
      'correct_index': 1,
      'explanation': 'Das Partizip I (z.B. lesend) drückt aus, dass eine Handlung gerade stattfindet (aktiv).',
    });
    await db.insert('grammar_quizzes', {
      'topic_id': 'c1_partizipialattribute',
      'question': 'Welches Partizip drückt Vorzeitigkeit/Passiv aus?',
      'options_json': json.encode([
        'Partizip I',
        'Partizip II',
        'Gerundium',
        'Supinum',
      ]),
      'correct_index': 1,
      'explanation': 'Das Partizip II (z.B. gelesen) drückt eine abgeschlossene Handlung aus (oft passivisch).',
    });
    await db.insert('grammar_quizzes', {
      'topic_id': 'c1_partizipialattribute',
      'question': 'Wie lautet das Partizip I von "schreiben"?',
      'options_json': json.encode([
        'geschrieben',
        'schreibend',
        'schrieb',
        'schreiben',
      ]),
      'correct_index': 1,
      'explanation': 'Das Partizip I wird durch Anhängen von "d" an den Infinitiv gebildet: schreibend.',
    });

    // Seed C2
    await db.insert('grammar_topics', {
      'id': 'c2_feste_nomen_verb',
      'level': 'C2',
      'title_de': 'Feste Nomen-Verb-Verbindungen',
      'title_ar': 'المركبات الاسمية الفعلية',
      'explanation_markdown': 'Feststehende Ausdrücke aus Nomen und Verb.',
      'formula_pattern': 'Nomen + Verb',
      'order_index': 1,
      'is_mastered': 0,
    });

    // Seed C2 Quizzes
    await db.insert('grammar_quizzes', {
      'topic_id': 'c2_feste_nomen_verb',
      'question': 'Welches Verb passt: "eine Entscheidung ___"?',
      'options_json': json.encode(['machen', 'tun', 'treffen', 'geben']),
      'correct_index': 2,
      'explanation': 'Die korrekte Nomen-Verb-Verbindung ist "eine Entscheidung treffen" (entscheiden).',
    });
    await db.insert('grammar_quizzes', {
      'topic_id': 'c2_feste_nomen_verb',
      'question': 'Welches Verb passt: "Abschied ___"?',
      'options_json': json.encode(['nehmen', 'machen', 'sagen', 'geben']),
      'correct_index': 0,
      'explanation': 'Die korrekte Nomen-Verb-Verbindung ist "Abschied nehmen" (sich verabschieden).',
    });
    await db.insert('grammar_quizzes', {
      'topic_id': 'c2_feste_nomen_verb',
      'question': 'Welches Verb passt: "in Frage ___"?',
      'options_json': json.encode(['stehen', 'stellen', 'kommen', 'machen']),
      'correct_index': 2,
      'explanation': '"in Frage kommen" bedeutet möglich sein / relevant sein.',
    });
  }

  Future<List<GrammarTopic>> getTopicsByLevel(String level) async {
    final db = await database;
    final maps = await db.query(
      'grammar_topics',
      where: 'level = ?',
      whereArgs: [level],
      orderBy: 'order_index ASC',
    );
    return maps.map((e) => GrammarTopic.fromMap(e)).toList();
  }

  Future<GrammarTopic?> getTopicDetail(String topicId) async {
    final db = await database;
    final maps = await db.query(
      'grammar_topics',
      where: 'id = ?',
      whereArgs: [topicId],
    );
    if (maps.isNotEmpty) {
      return GrammarTopic.fromMap(maps.first);
    }
    return null;
  }

  Future<List<GrammarQuiz>> getQuizzesForTopic(String topicId) async {
    final db = await database;
    final maps = await db.query(
      'grammar_quizzes',
      where: 'topic_id = ?',
      whereArgs: [topicId],
    );
    return maps.map((e) => GrammarQuiz.fromMap(e)).toList();
  }

  Future<void> saveTopicMastery(String topicId, bool mastered) async {
    final db = await database;
    await db.update(
      'grammar_topics',
      {'is_mastered': mastered ? 1 : 0},
      where: 'id = ?',
      whereArgs: [topicId],
    );
  }

  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
