import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'database_service.dart';

class DeckExportWord {
  const DeckExportWord({
    required this.lexemeId,
    required this.languageCode,
    required this.front,
    required this.back,
    required this.tag,
    this.example,
    this.grammar,
    this.cefr,
  });

  final String lexemeId;
  final String languageCode;
  final String front;
  final String back;
  final String tag;
  final String? example;
  final String? grammar;
  final String? cefr;
}

/// Local-only personal taxonomy and Anki 2.1 legacy package exporter.
///
/// Tags live in the writable progress DB; content packs remain read-only.
/// A package contains collection.anki2 and media JSON (empty media map).
/// Anki cards intentionally import as new; scheduling state is not silently
/// mapped between incompatible schedulers.
class DeckExportService {
  DeckExportService({
    Future<Database> Function()? progressDb,
    Future<Database> Function(String)? contentDb,
    Future<Directory> Function()? downloadsDirectory,
    Future<Directory> Function()? temporaryDirectory,
  })  : _progressDb = progressDb ?? (() => DatabaseService.instance.progressDb),
        _contentDb = contentDb ??
            ((language) => DatabaseService.instance.getContentDb(language)),
        _downloadsDirectory = downloadsDirectory ?? _defaultDownloads,
        _temporaryDirectory = temporaryDirectory ?? getTemporaryDirectory;

  final Future<Database> Function() _progressDb;
  final Future<Database> Function(String) _contentDb;
  final Future<Directory> Function() _downloadsDirectory;
  final Future<Directory> Function() _temporaryDirectory;

  static Future<Directory> _defaultDownloads() async {
    // On Android, never write directly to the public Downloads directory:
    // scoped storage can deny dart:io writes even when a path is returned.
    // The caller can share the resulting app-private file via the system UI.
    if (!Platform.isAndroid) {
      try {
        final downloads = await getDownloadsDirectory();
        if (downloads != null) return downloads;
      } catch (_) {
        // A system Downloads directory is not available on every platform.
      }
    }
    final documents = await getApplicationDocumentsDirectory();
    return Directory(p.join(documents.path, 'exports'));
  }

  Future<void> _ensureTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS custom_decks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE COLLATE NOCASE
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS custom_deck_words (
        deck_id INTEGER NOT NULL,
        language_code TEXT NOT NULL,
        lexeme_id TEXT NOT NULL,
        PRIMARY KEY (deck_id, language_code, lexeme_id)
      )
    ''');
  }

  Future<void> tagWords({
    required String deckName,
    required String languageCode,
    required Iterable<String> lexemeIds,
  }) async {
    final name = _validateName(deckName);
    final language = _language(languageCode);
    final db = await _progressDb();
    await _ensureTables(db);
    await db.transaction((transaction) async {
      await transaction.rawInsert(
        'INSERT OR IGNORE INTO custom_decks(name) VALUES (?)',
        <Object?>[name],
      );
      final found = await transaction.rawQuery(
        'SELECT id FROM custom_decks WHERE name = ? COLLATE NOCASE',
        <Object?>[name],
      );
      final deckId = found.first['id'] as int;
      for (final rawId in lexemeIds.toSet()) {
        final id = rawId.trim();
        if (id.isEmpty) continue;
        await transaction.rawInsert(
          'INSERT OR IGNORE INTO custom_deck_words '
          '(deck_id, language_code, lexeme_id) VALUES (?, ?, ?)',
          <Object?>[deckId, language, id],
        );
      }
    });
  }

  Future<List<DeckExportWord>> loadWords({
    required String deckName,
    bool dueOnly = false,
    DateTime? now,
    int limit = 5000,
  }) async {
    final name = _validateName(deckName);
    if (limit < 1 || limit > 5000) {
      throw RangeError.range(limit, 1, 5000, 'limit');
    }
    final db = await _progressDb();
    await _ensureTables(db);
    final dueClause =
        dueOnly ? 'AND (p.next_due_at IS NULL OR p.next_due_at <= ?)' : '';
    final args = <Object?>[name];
    if (dueOnly) {
      args.add((now ?? DateTime.now()).millisecondsSinceEpoch ~/ 1000);
    }
    args.add(limit);
    final progress = await db.rawQuery('''
      SELECT p.lexeme_id, p.target_language_code
      FROM custom_deck_words AS t
      JOIN custom_decks AS d ON d.id = t.deck_id
      JOIN srs_progress AS p
        ON p.lexeme_id = t.lexeme_id
       AND p.target_language_code = t.language_code
      WHERE d.name = ? COLLATE NOCASE $dueClause
      ORDER BY p.target_language_code, p.lexeme_id
      LIMIT ?
    ''', args);
    final byLanguage = <String, List<String>>{};
    for (final row in progress) {
      final code = _language(row['target_language_code'].toString());
      byLanguage
          .putIfAbsent(code, () => <String>[])
          .add(row['lexeme_id'].toString());
    }
    final words = <DeckExportWord>[];
    for (final item in byLanguage.entries) {
      final Database content;
      try {
        content = await _contentDb(item.key);
      } catch (_) {
        continue; // Unmounted pack must not corrupt an otherwise valid export.
      }
      for (var start = 0; start < item.value.length; start += 300) {
        final end =
            start + 300 < item.value.length ? start + 300 : item.value.length;
        final ids = item.value.sublist(start, end);
        final placeholders = List<String>.filled(ids.length, '?').join(',');
        final List<Map<String, Object?>> rows;
        try {
          rows = await content.rawQuery(
            'SELECT id, surface, fields_json FROM lexicon WHERE id IN ($placeholders)',
            ids,
          );
        } catch (_) {
          continue;
        }
        for (final row in rows) {
          final front = (row['surface'] ?? '').toString().trim();
          if (front.isEmpty) continue;
          Map<String, dynamic> fields = <String, dynamic>{};
          try {
            final decoded = jsonDecode((row['fields_json'] ?? '{}').toString());
            if (decoded is Map) fields = Map<String, dynamic>.from(decoded);
          } on FormatException {
            // Malformed optional metadata does not break the whole deck.
          }
          final back = (fields['translation_ar'] ?? fields['translation'] ?? '')
              .toString();
          final isCefrVerified = fields['isCefrVerified'] == true;
          final example = isCefrVerified ? fields['example_ar']?.toString() : null;
          final grammar = isCefrVerified ? fields['grammar']?.toString() : null;
          final cefr = isCefrVerified ? fields['cefr']?.toString() : null;
          words.add(DeckExportWord(
            lexemeId: row['id'].toString(),
            languageCode: item.key,
            front: front,
            back: back,
            tag: name.replaceAll(RegExp(r'\s+'), '_'),
            example: example,
            grammar: grammar,
            cefr: cefr,
          ));
        }
      }
    }
    words.sort((a, b) {
      final language = a.languageCode.compareTo(b.languageCode);
      return language != 0 ? language : a.lexemeId.compareTo(b.lexemeId);
    });
    return words;
  }

  /// UTF-8 tab-separated CSV, compatible with Anki text import.
  Future<File> exportCsv({
    required String deckName,
    bool dueOnly = false,
  }) async {
    final words = await loadWords(deckName: deckName, dueOnly: dueOnly);
    final buffer = StringBuffer('Front\tBack\tTags\n');
    for (final word in words) {
      buffer.writeln(
        '${_tsv(word.front)}\t${_tsv(word.back)}\t${_tsv(word.tag)}',
      );
    }
    final directory = await _downloadsDirectory();
    await directory.create(recursive: true);
    final file = File(p.join(directory.path, '${_fileStem(deckName)}.csv'));
    return file.writeAsString(buffer.toString(), encoding: utf8, flush: true);
  }

  /// Produces a standard zip APKG with a real Anki v11 SQLite collection.
  Future<File> exportAnkiApkg({
    required String deckName,
    bool dueOnly = false,
  }) async {
    final name = _validateName(deckName);
    final words = await loadWords(deckName: name, dueOnly: dueOnly);
    final temporaryRoot = await _temporaryDirectory();
    final scratch = Directory(p.join(
      temporaryRoot.path,
      'anki_${DateTime.now().microsecondsSinceEpoch}',
    ));
    await scratch.create(recursive: true);
    Database? db;
    try {
      final collectionFile = File(p.join(scratch.path, 'collection.anki2'));
      db = await openDatabase(collectionFile.path, singleInstance: false);
      await _createAnkiSchema(db);
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      final nowS = nowMs ~/ 1000;
      final deckId = nowMs;
      final modelId = nowMs + 1;
      final model = _basicModel(modelId, deckId, nowS);
      final decks = <String, Object?>{
        deckId.toString(): <String, Object?>{
          'id': deckId,
          'name': name,
          'mod': nowS,
          'usn': -1,
          'desc': '',
          'dyn': 0,
          'collapsed': false,
          'browserCollapsed': false,
          'conf': 1,
          'extendNew': 0,
          'extendRev': 0,
        },
      };
      final config = <String, Object?>{
        'nextPos': words.length + 1,
        'curDeck': deckId,
        'activeDecks': <int>[deckId],
        'sortType': 'noteFld',
        'sortBackwards': false,
        'addToCur': true,
        'newBury': true,
        'newSpread': 0,
        'collapseTime': 1200,
        'timeLim': 0,
      };
      await db.rawInsert(
        'INSERT INTO col '
        '(id,crt,mod,scm,ver,dty,usn,ls,conf,models,decks,dconf,tags) '
        'VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)',
        <Object?>[
          1,
          nowS,
          nowMs,
          nowMs,
          11,
          0,
          -1,
          0,
          jsonEncode(config),
          jsonEncode(<String, Object?>{
            modelId.toString(): model,
          }),
          jsonEncode(decks),
          jsonEncode(_deckConfig(nowS)),
          '{}',
        ],
      );

      final firstId = DateTime.now().microsecondsSinceEpoch;
      await db.transaction((txn) async {
        for (var i = 0; i < words.length; i++) {
          final word = words[i];
          final noteId = firstId + i * 2;
          final cardId = noteId + 1;
          final fieldText = '${_html(word.front)}\u001f${_html(word.back)}'
              '\u001f${_html(word.example ?? '')}'
              '\u001f${_html(word.grammar ?? '')}'
              '\u001f${_html(word.cefr ?? '')}';
          final hash = sha1.convert(utf8.encode(word.front)).toString();
          final checksum = int.parse(hash.substring(0, 8), radix: 16);
          await txn.rawInsert(
            'INSERT INTO notes '
            '(id,guid,mid,mod,usn,tags,flds,sfld,csum,flags,data) '
            'VALUES (?,?,?,?,?,?,?,?,?,?,?)',
            <Object?>[
              noteId,
              noteId.toRadixString(36),
              modelId,
              nowS,
              -1,
              ' ${word.tag} ',
              fieldText,
              word.front,
              checksum,
              0,
              '',
            ],
          );
          await txn.rawInsert(
            'INSERT INTO cards '
            '(id,nid,did,ord,mod,usn,type,queue,due,ivl,factor,reps,lapses,'
            'left,odue,odid,flags,data) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
            <Object?>[
              cardId,
              noteId,
              deckId,
              0,
              nowS,
              -1,
              0,
              0,
              i + 1,
              0,
              2500,
              0,
              0,
              0,
              0,
              0,
              0,
              '',
            ],
          );
        }
      });
      await db.close();
      db = null;
      final sqliteBytes = await collectionFile.readAsBytes();
      final mediaBytes = utf8.encode('{}');
      final contentHash = sha1.convert(utf8.encode(
          words.map((w) => w.front).join(''))).toString();
      final manifestBytes = utf8.encode(jsonEncode(<String, Object?>{
        'version': 1,
        'checksum': contentHash,
        'timestamp': DateTime.now().toIso8601String(),
      }));
      final archive = Archive()
        ..addFile(
            ArchiveFile('collection.anki2', sqliteBytes.length, sqliteBytes))
        ..addFile(ArchiveFile('media', mediaBytes.length, mediaBytes))
        ..addFile(ArchiveFile('manifest.json', manifestBytes.length, manifestBytes));
      final encoded = ZipEncoder().encode(archive);
      final directory = await _downloadsDirectory();
      await directory.create(recursive: true);
      final finalPath = p.join(directory.path, '${_fileStem(name)}.apkg');
      final tempOutput = File('$finalPath.tmp');
      try {
        await tempOutput.writeAsBytes(encoded, flush: true);
        // Verify archive structure
        final verifyBytes = await tempOutput.readAsBytes();
        final verifyArchive = ZipDecoder().decodeBytes(verifyBytes, verify: true);
        if (verifyArchive.findFile('collection.anki2') == null ||
            verifyArchive.findFile('media') == null ||
            verifyArchive.findFile('manifest.json') == null) {
          throw const FormatException('Archive verification failed');
        }
        final output = File(finalPath);
        if (await output.exists()) {
            await output.delete();
        }
        return await tempOutput.rename(finalPath);
      } catch (e) {
        if (await tempOutput.exists()) {
          await tempOutput.delete();
        }
        rethrow;
      }
    } finally {
      if (db != null && db.isOpen) await db.close();
      if (await scratch.exists()) await scratch.delete(recursive: true);
    }
  }

  static Future<void> _createAnkiSchema(Database db) async {
    for (final sql in <String>[
      'CREATE TABLE col (id integer primary key,crt integer,mod integer,'
          'scm integer,ver integer,dty integer,usn integer,ls integer,'
          'conf text,models text,decks text,dconf text,tags text)',
      'CREATE TABLE notes (id integer primary key,guid text,mid integer,'
          'mod integer,usn integer,tags text,flds text,sfld text,csum integer,'
          'flags integer,data text)',
      'CREATE TABLE cards (id integer primary key,nid integer,did integer,'
          'ord integer,mod integer,usn integer,type integer,queue integer,'
          'due integer,ivl integer,factor integer,reps integer,lapses integer,'
          'left integer,odue integer,odid integer,flags integer,data text)',
      'CREATE TABLE revlog (id integer primary key,cid integer,usn integer,'
          'ease integer,ivl integer,lastIvl integer,factor integer,'
          'time integer,type integer)',
      'CREATE TABLE graves (usn integer,oid integer,type integer)',
      'CREATE INDEX ix_notes_usn ON notes(usn)',
      'CREATE INDEX ix_cards_usn ON cards(usn)',
      'CREATE INDEX ix_revlog_usn ON revlog(usn)',
      'CREATE INDEX ix_cards_nid ON cards(nid)',
      'CREATE INDEX ix_cards_sched ON cards(did,queue,due)',
      'CREATE INDEX ix_notes_csum ON notes(csum)',
      'CREATE INDEX ix_revlog_cid ON revlog(cid)',
    ]) {
      await db.execute(sql);
    }
  }

  static Map<String, Object?> _basicModel(int modelId, int deckId, int now) =>
      <String, Object?>{
        'id': modelId,
        'name': 'DEUTSCH Export Basic',
        'type': 0,
        'mod': now,
        'usn': -1,
        'sortf': 0,
        'did': deckId,
        'latexPre': '',
        'latexPost': '',
        'css':
            '.card { font-family: Arial; font-size: 20px; text-align: center; }',
        'flds': <Map<String, Object?>>[
          <String, Object?>{
            'name': 'Front',
            'ord': 0,
            'sticky': false,
            'rtl': false,
            'font': 'Arial',
            'size': 20
          },
          <String, Object?>{
            'name': 'Back',
            'ord': 1,
            'sticky': false,
            'rtl': true,
            'font': 'Arial',
            'size': 20
          },
          <String, Object?>{
            'name': 'Example',
            'ord': 2,
            'sticky': false,
            'rtl': true,
            'font': 'Arial',
            'size': 20
          },
          <String, Object?>{
            'name': 'Grammar',
            'ord': 3,
            'sticky': false,
            'rtl': false,
            'font': 'Arial',
            'size': 20
          },
          <String, Object?>{
            'name': 'CEFR',
            'ord': 4,
            'sticky': false,
            'rtl': false,
            'font': 'Arial',
            'size': 20
          },
        ],
        'tmpls': <Map<String, Object?>>[
          <String, Object?>{
            'name': 'Card 1',
            'ord': 0,
            'qfmt': '{{Front}}',
            'afmt': '{{FrontSide}}<hr id=answer>{{Back}}<br>{{Example}}<br>{{Grammar}}<br>{{CEFR}}',
          },
        ],
        'req': <Object?>[
          <Object?>[
            0,
            'any',
            <int>[0]
          ],
        ],
        'tags': <String>[],
      };

  static Map<String, Object?> _deckConfig(int now) => <String, Object?>{
        '1': <String, Object?>{
          'id': 1,
          'name': 'Default',
          'mod': now,
          'usn': -1,
          'maxTaken': 60,
          'autoplay': true,
          'timer': 0,
          'replayq': true,
          'new': <String, Object?>{
            'bury': true,
            'delays': <int>[1, 10],
            'initialFactor': 2500,
            'ints': <int>[1, 4, 7],
            'order': 1,
            'perDay': 20,
            'separate': true,
          },
          'rev': <String, Object?>{
            'bury': true,
            'ease4': 1.3,
            'fuzz': 0.05,
            'ivlFct': 1,
            'maxIvl': 36500,
            'minSpace': 1,
            'perDay': 200,
          },
          'lapse': <String, Object?>{
            'delays': <int>[10],
            'leechAction': 0,
            'leechFails': 8,
            'minInt': 1,
            'mult': 0,
          },
        },
      };

  static String _html(String text) => text
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
  static String _tsv(String text) =>
      text.replaceAll(RegExp(r'[\t\r\n]+'), ' ').trim();
  static String _fileStem(String name) {
    final safe = _validateName(name).replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    return '${safe.isEmpty ? 'deck' : safe}_${DateTime.now().microsecondsSinceEpoch}';
  }

  static String _validateName(String value) {
    final name = value.trim();
    if (name.contains(RegExp(r'[/\\]')) || name.contains('.')) {
      throw ArgumentError.value(value, 'deckName', 'Invalid characters in deck name');
    }
    if (name.isEmpty || name.length > 80) {
      throw ArgumentError.value(value, 'deckName', 'Must be 1-80 characters');
    }
    return name;
  }

  static String _language(String raw) {
    final code = raw.trim().toLowerCase().replaceAll('_', '-');
    if (!RegExp(r'^[a-z]{2,3}(?:-[a-z0-9]{2,8})*$').hasMatch(code)) {
      throw ArgumentError.value(raw, 'languageCode', 'Invalid language code');
    }
    return code.split('-').first;
  }
}
