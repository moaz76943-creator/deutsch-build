import 'package:flutter/material.dart';

import '../services/database_service.dart';
import '../services/language_pack_manager.dart';

/// The content-pack schema stores idioms against the stable `lexicon.id`.
class IdiomEntry {
  const IdiomEntry({
    required this.id,
    required this.headwordId,
    required this.expression,
    required this.translationAr,
    this.separablePrefix,
  });

  final String id;
  final String headwordId;
  final String expression;
  final String translationAr;
  final String? separablePrefix;

  factory IdiomEntry.fromDatabaseRow(Map<String, Object?> row) {
    final prefix = row['separable_prefix']?.toString().trim();
    return IdiomEntry(
      id: row['id']!.toString(),
      headwordId: row['headword_id']!.toString(),
      expression: row['expression']!.toString(),
      translationAr: row['translation_ar']!.toString(),
      separablePrefix: prefix == null || prefix.isEmpty ? null : prefix,
    );
  }
}

/// An injectable asynchronous repository boundary, useful for worker-backed
/// content lookups or preloaded headword details.
typedef IdiomsLoader = Future<List<IdiomEntry>> Function(
  String headwordId,
  String languageCode,
);

/// Add below a headword definition: IdiomsView(headwordId: entry['id']).
///
/// SQL is issued asynchronously, never synchronously from a build/animation
/// frame. The optional [loader] lets callers route lookups through a worker.
/// When the pack lacks the optional `idioms` table or has no matching records,
/// nothing is rendered (including no empty heading or card).
class IdiomsView extends StatefulWidget {
  const IdiomsView({
    super.key,
    required this.headwordId,
    this.languageCode = 'de',
    this.loader,
  });

  final String headwordId;
  final String languageCode;
  final IdiomsLoader? loader;

  @override
  State<IdiomsView> createState() => _IdiomsViewState();
}

class _IdiomsViewState extends State<IdiomsView> {
  static final RegExp _letter = RegExp(r'[\p{L}\p{M}]', unicode: true);
  late Future<List<IdiomEntry>> _idioms;

  @override
  void initState() {
    super.initState();
    _idioms = _load();
  }

  @override
  void didUpdateWidget(covariant IdiomsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.headwordId != widget.headwordId ||
        oldWidget.languageCode != widget.languageCode ||
        oldWidget.loader != widget.loader) {
      _idioms = _load();
    }
  }

  Future<List<IdiomEntry>> _load() {
    final headwordId = widget.headwordId.trim();
    if (headwordId.isEmpty) {
      return Future<List<IdiomEntry>>.value(const <IdiomEntry>[]);
    }
    return (widget.loader ?? _loadFromContentPack)(
      headwordId,
      widget.languageCode,
    );
  }

  static Future<List<IdiomEntry>> _loadFromContentPack(
    String headwordId,
    String languageCode,
  ) async {
    final db = await DatabaseService.instance.getContentDb(languageCode);
    try {
      final rows = await db.query(
        'idioms',
        columns: const <String>[
          'id',
          'headword_id',
          'expression',
          'translation_ar',
          'separable_prefix',
        ],
        where: 'headword_id = ?',
        whereArgs: <Object>[headwordId],
        orderBy: 'expression ASC, id ASC',
      );
      return rows.map(IdiomEntry.fromDatabaseRow).toList(growable: false);
    } catch (error) {
      // Older packs predate Track 25 and must remain usable and read-only.
      if (error.toString().toLowerCase().contains('no such table: idioms')) {
        return const <IdiomEntry>[];
      }
      rethrow;
    }
  }

  static bool _isLetter(String character) =>
      character.isNotEmpty && _letter.hasMatch(character);

  /// Highlights standalone English particles (take *off*) and word-initial
  /// German separable prefixes (*an*rufen), without highlighting substrings
  /// inside unrelated English words such as "offer".
  static List<InlineSpan> _expressionSpans(
    String expression,
    String? rawPrefix,
    String languageCode,
    Color highlightColor,
  ) {
    final prefix = rawPrefix?.trim() ?? '';
    if (prefix.isEmpty) return <InlineSpan>[TextSpan(text: expression)];

    final german =
        languageCode.toLowerCase().split(RegExp(r'[-_]')).first == 'de';
    final spans = <InlineSpan>[];
    var copiedThrough = 0;

    // RegExp reports offsets in the original string, including for Unicode.
    final matches = RegExp(
      RegExp.escape(prefix),
      caseSensitive: false,
      unicode: true,
    ).allMatches(expression);
    for (final match in matches) {
      final start = match.start;
      final end = match.end;
      final before = start == 0
          ? ''
          : String.fromCharCode(expression.substring(0, start).runes.last);
      final after = end == expression.length
          ? ''
          : String.fromCharCode(expression.substring(end).runes.first);
      final wordStart = !_isLetter(before);
      final isolated = !_isLetter(after);

      if (wordStart && (isolated || german)) {
        if (copiedThrough < start) {
          spans.add(TextSpan(text: expression.substring(copiedThrough, start)));
        }
        spans.add(TextSpan(
          text: expression.substring(start, end),
          style: TextStyle(
            color: highlightColor,
            fontWeight: FontWeight.bold,
          ),
        ));
        copiedThrough = end;
      }
    }

    if (copiedThrough < expression.length) {
      spans.add(TextSpan(text: expression.substring(copiedThrough)));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<IdiomEntry>>(
      future: _idioms,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'تعذّر تحميل التعابير',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        }
        final entries = snapshot.data ?? const <IdiomEntry>[];
        if (entries.isEmpty) return const SizedBox.shrink();

        final theme = Theme.of(context);
        final sourceDirection =
            LanguagePackManager.isRtlLanguage(widget.languageCode)
            ? TextDirection.rtl
            : TextDirection.ltr;
        return Card(
          clipBehavior: Clip.antiAlias,
          child: ExpansionTile(
            leading: const Icon(Icons.format_quote_rounded),
            title: const Text('التعابير والعبارات المركّبة'),
            subtitle: Text('${entries.length} تعبير'),
            children: <Widget>[
              for (var index = 0; index < entries.length; index++) ...<Widget>[
                if (index > 0) const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text.rich(
                        TextSpan(
                          children: _expressionSpans(
                            entries[index].expression,
                            entries[index].separablePrefix,
                            widget.languageCode,
                            theme.colorScheme.primary,
                          ),
                        ),
                        textDirection: sourceDirection,
                        textAlign: TextAlign.start,
                        style: theme.textTheme.titleMedium,
                        semanticsLabel: entries[index].expression,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entries[index].translationAr,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.start,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
